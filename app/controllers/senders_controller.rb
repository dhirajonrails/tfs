require 'rest_client'

class SendersController < ApplicationController
  before_action :authenticate_user!, :is_merchant?, :build_merchant

  PER_PAGE = 10

  def index
    index_headers
    load_transaction
  end

  def rejected_request
    index_headers
    @transactions = Transaction.joins([:sender, :merchant, beneficiary: [:bank_detail]]).where('merchant_mobile = ? and status IN ("Delete Transaction", "REJECT/RETURN")', current_user.merchant.mobile).distinct.page(params[:page]).per(PER_PAGE).order(created_at: :desc)
  end

  def new
    @sender = @merchant.senders.build
    @beneficiaries = @merchant.beneficiaries.build
    @transactions = @merchant.transactions.build
  end

  def create
    ActiveRecord::Base.transaction do
      sender = Sender.find_by_mobile(params[:sender][:mobile]) || Sender.new
      sender.attributes = sender_params
      sender.save!
      beneficiary = Beneficiary.find_by_account_number(account_number_param) || Beneficiary.new
      beneficiary.attributes = register_params[:beneficiaries_attributes]['0']
      beneficiary.save!
      bank_detail = BankDetail.find_by_ifsc_code(params[:bank][:ifsc_code])
      unless bank_detail.present?
        bank_detail = BankDetail.new
        bank_detail.attributes = bank_params
      end
      bank_detail.save!
      beneficiary.update_attributes!(bank_detail_id: bank_detail.id, ifsc_code: bank_detail.ifsc_code, hidden:false)
      transaction = beneficiary.transactions.build(transaction_params)
      transaction.merchant_mobile = current_user.merchant.mobile
      transaction.sender_mobile = sender.mobile
      transaction.status = 'In Process'
      transaction.hidden = false
      transaction.updated = false
      transaction.quick_transfer = params[:transaction][:quick_transfer].present? ? params[:transaction][:quick_transfer] : false
      dist_mobile = current_user.merchant.distributor.mobile rescue nil
      transaction.distributor_mobile = dist_mobile
      transaction.save!
      txt_id = "#{transaction.created_at.strftime("%d%m")}#{transaction.id}"
      if transaction.quick_transfer
        charges = Transaction.quick_request(transaction.amount)
        transaction.update!(charges: charges)
        # transaction.notifications.create!(distributor_id: @merchant.distributor.try(:id), read_by_admin: false, read_by_distributor: false, quick_transfer: @transaction.quick_transfer)
        new_limit =  @merchant.quick_limit - transaction.amount - transaction.charges
        change_limit = @merchant.change_limits.create!(amount: transaction.amount + transaction.charges,
                                        previous_limit: @merchant.quick_limit, distributor_mobile: dist_mobile,
                                        current_limit: new_limit, source: 'transaction',
                                        action: 'less', note: transaction.merchant_remark, quick_request: true, status: 'Transaction')
        transaction.update_attributes!(txt_id: txt_id, current_limit: new_limit, previous_limit: @merchant.quick_limit, downloaded: false)
        @merchant.update_attributes!(:quick_limit => new_limit)
      else
        charges = Transaction.normal_request(transaction.amount)
        transaction.update!(charges: charges)
        new_limit =  @merchant.balance_limit - transaction.amount - transaction.charges
        change_limit = @merchant.change_limits.create!(amount: transaction.amount + transaction.charges,
                                        previous_limit: @merchant.balance_limit,
                                        current_limit: new_limit, source: 'transaction', distributor_mobile: dist_mobile,
                                        action: 'less',note: transaction.merchant_remark, quick_request: false, status: 'Transaction')
        transaction.update_attributes!(txt_id: txt_id, current_limit: new_limit, previous_limit: @merchant.balance_limit)
        @merchant.update_attributes!(:balance_limit => new_limit)
      end
      message = "Beneficiary: #{beneficiary.name}, Your A/C No:#{beneficiary.account_number}, Rs.#{transaction.amount} has been done with TXNID #{transaction.txt_id} on #{transaction.created_at.strftime("%d-%m-%y at %I:%M%p")} from TFS"
      RestClient.get "http://login.smsgatewayhub.com/api/mt/SendSMS?APIKey=867ea61b-4a1d-4187-ae4f-610771e0c05e&senderid=TFASMT&channel=2&DCS=0&flashsms=0&number=#{sender.mobile}&text=#{message}&route=11" rescue nil
      redirect_to senders_path, flash: { success: "Transaction successfully created with id #{transaction.txt_id}"}
    end
  rescue Exception => error
    redirect_to request.referrer, flash: { error:  "#{error}"}
  end

  def search
    index_headers
    query = []
    query << "transactions.created_at <= '#{params[:end].to_date.end_of_day}'" if params[:end].present?
    query << "transactions.created_at >= '#{params[:start].to_date.beginning_of_day}'" if params[:start].present?
    if params[:start].present? && params[:end].present?
      query = []
      query << "transactions.created_at BETWEEN '#{params[:start].to_date.beginning_of_day}' AND '#{params[:end].to_date.end_of_day}'"
    end
    query << "merchants.id = #{current_user.merchant.id} and (beneficiaries.account_number LIKE '%#{params[:search]}%' or transactions.txt_id LIKE '%#{params[:search]}%' or senders.name LIKE '%#{params[:search]}%' or beneficiaries.name LIKE '%#{params[:search]}%' or beneficiaries.account_number LIKE '%#{params[:search]}%' or beneficiaries.ifsc_code LIKE '%#{params[:search]}%')"
    query << "quick_transfer = #{params[:request]}" if params[:request].present?
    if params[:status] == 'rejected'
      query << "status IN ('Delete Transaction', 'REJECT/RETURN')"
    elsif params[:status].present?
      query << "status = '#{params[:status]}'"
    end
    @transactions = Transaction.joins([:beneficiary, :sender, :merchant]).includes([ :sender, :merchant, beneficiary:[:bank_detail]])
                                .where(query.join(' AND ')).distinct.page(params[:page]).per(PER_PAGE).order(created_at: :desc)
    if @transactions.present?
      unless params[:status] == 'rejected'
        render 'index'
      else
        render 'rejected_request'
      end
    else
      unless params[:status] == 'rejected'
        render 'index', flash: { error: 'No data found' }
      else
        render 'rejected_request', flash: { error: 'No data found' }
      end
    end
  end

  def charge
    if params[:quick_transfer] == 'true'
      value = Transaction.quick_request(params[:amount].to_i)
    else
      value = Transaction.normal_request(params[:amount].to_i)
    end
    render json: { total: params[:amount].to_i + value, status: 200 }
  end

  def search_by_mobile
    sender = Sender.find_by_mobile(params[:mobile])
    if sender.present?
      render json: { sender: sender, status: 200 }
    else
      render json: { sender: sender, status: 404 }
    end
  end

  def validate_number
    sender = Sender.find_by_mobile(params[:mobile])
    if sender.present?
      render json: { sender: sender, status: 200 }
    else
      render json: { sender: sender, status: 404 }
    end
  end

  def validate_account
    beneficiary = Beneficiary.find_by_account_number(params[:account_number])
    if beneficiary.present?
      render json: { status: 200 }
    else
      render json: { status: 404 }
    end
  end

  def search_by_account_number
    beneficiary = Beneficiary.find_by_account_number(params[:account_number])
    if beneficiary.present?
      render json: { beneficiary: beneficiary,
                     bank_detail: beneficiary.bank_detail,
                     status: 200 }
    else
      render json: { status: 404 }
    end
  end

  def beneficiaries
    sender = Sender.find_by_mobile(params[:mobile])
    beneficiaries = sender.beneficiaries.where(hidden:false).distinct
    if beneficiaries.present?
      render json: { beneficiaries: beneficiaries, status: 200 }
    else
      render json: { status: 404 }
    end
  end

  def existing_senders
    beneficiary = Beneficiary.find_by_account_number(params[:account_number])
    if beneficiary.present?
      render json: { senders: beneficiary.senders.distinct,
                     status: 200 }
    else
      render json: { status: 404 }
    end
  end

  def search_sender_detail
    sender = Sender.find_by_mobile(params[:mobile])
    if sender.present?
      render json: { sender: sender,
                     status: 200 }
    else
      render json: { status: 404 }
    end
  end


  def search_bank_detail
    bank_detail = BankDetail.find_by_ifsc_code(params[:ifsc])
    if bank_detail.present?
      render json: { bank_detail: bank_detail, status: 200 }
    else
      render json: { status: 404 }
    end
  end

  def delete_beneficiary
    beneficiary = Beneficiary.find_by_account_number(params[:account_number])
    sender = Sender.find_by_mobile(params[:mobile])
    if beneficiary.present?
      beneficiary.update(hidden: true)
      beneficiaries = sender.beneficiaries.where(hidden:false)
      render json: { beneficiaries: beneficiaries, status: 200 }
    else
      render json: { status: 404 }
    end
  end

  def build_merchant
    @merchant = current_user.merchant
  end

  def register_params
    params.require(:sender).permit!
  end

  def transaction_params
    params.require(:transaction).permit(:amount)
  end

  def bank_params
    params.require(:bank).permit!
  end

  def account_number_param
    params[:sender][:beneficiaries_attributes]['0'][:account_number]
  end

  def sender_params
    params.require(:sender).permit(:name, :mobile, :id_proof, :address)
  end

  def load_transaction
    @transactions = Transaction.joins([:sender, :merchant, beneficiary: [:bank_detail]]).where('merchant_mobile = ? and status!="Delete Transaction"', current_user.merchant.mobile).distinct.page(params[:page]).per(PER_PAGE).order(created_at: :desc)
  end

  def index_headers
    quick_add = current_user.merchant.change_limits.where('quick_request=true and action="add" and source!="transaction"').sum(:amount)
    quick_less = current_user.merchant.change_limits.where('quick_request=true and action="less" and source!="transaction"').sum(:amount)
    @quick_total = quick_add - quick_less
    normal_add = current_user.merchant.change_limits.where('quick_request=false and action="add" and source!="transaction"').sum(:amount)
    normal_less = current_user.merchant.change_limits.where('quick_request=false and action="less" and source!="transaction"').sum(:amount)
    @normal_total = normal_add - normal_less
  end

  def download_service_request
    @transactions = Transaction.joins([:sender, :merchant, beneficiary: [:bank_detail]]).where("merchant_mobile = ? and status!='Delete Transaction' and transactions.created_at BETWEEN '#{params[:start].to_date.beginning_of_day}' AND '#{params[:end].to_date.end_of_day}'", current_user.merchant.mobile).distinct.order(created_at: :desc)
    filename = "#{Date.today.strftime('%d-%m-%Y')}-Service-Request.xls"
    respond_to do |format|
      format.xls do
        response.headers['Content-Type'] = 'application/vnd.ms-excel; charset=utf-8'
        response.headers['Content-Disposition'] = "attachment; filename=#{filename}"
      end
    end
  end

  def download_invoice
    @transaction = Transaction.find(params[:id])
    html = render_to_string(action: :show, layout: 'invoice.html.haml',
                            template: 'senders/invoice.pdf.haml')
    pdf = WickedPdf.new.pdf_from_string(html)
    send_data(pdf,
              filename: 'invoice',
              disposition:'inline',
              type: 'application/pdf')
  end
end
