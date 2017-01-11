require 'csv'
class Admin::SendersController < ApplicationController
  include Permissions::TransactionPermissions

  before_action :authenticate_user!
  after_action :update_imps, only: [:download_quick_csv]
  before_action :normal_view_request_check, only: [:index]
  before_action :quick_view_request_check, only: [:quick_request]
  before_action :edit_request_check, only: [:edit]
  before_action :update_request_check, only: [:update]
  before_action :delete_request_check, only: [:destroy]
  before_action :bank_detail_check, only: [:bank_detail, :update_bank_detail]
  PER_PAGE = 10

  def index
    headers
    # Notification.where(quick_transfer: false).update_all(read_by_admin: true)
    load_transactions
  end

  def quick_request
    quick_headers
    # Notification.where(quick_transfer: true).update_all(read_by_admin: true)
    @transactions = Transaction.includes([:sender, merchant: [:profile, :user,  distributor:[:profile, :user]], beneficiary: [:bank_detail]]).where(quick_transfer: true, hidden: false).page(params[:page]).per(PER_PAGE).order(created_at: :desc)
  end

  def edit
    @transaction = Transaction.find(params[:id])
    # if @transaction.updated
    #   if  !request.referrer.nil?
    #     redirect_to request.referrer, flash:{ error:  'Already Updated' }
    #   elsif @transaction.quick_transfer
    #     redirect_to quick_request_admin_senders_path,  flash: { error:  'Already Updated' }
    #   else
    #     redirect_to admin_senders_path, flash: { error:  'Already Updated' }
    #   end
    # end
    @beneficiary = @transaction.beneficiary
    @sender = @transaction.sender
    @bank_detail = @beneficiary.bank_detail
  end

  def update
    ActiveRecord::Base.transaction do
      @transaction = Transaction.find(params[:id])
      status = params[:transaction][:status]
      if status.present?
        if status == 'REJECT/RETURN'
          @merchant = @transaction.merchant
          if @transaction.quick_transfer
            new_limit =  @merchant.quick_limit + @transaction.amount + @transaction.charges
            @change_limit = @merchant.change_limits.create!(amount: (@transaction.amount + @transaction.charges),
                                                             distributor_mobile: @transaction.distributor_mobile,
                                                             previous_limit: @merchant.quick_limit,
                                                             current_limit: new_limit, source: 'transaction',
                                                             action: 'add', note: @transaction.admin_remark,
                                                             quick_request: true, status: 'Transaction')
            @transaction.attributes = { current_limit: new_limit, previous_limit: @merchant.quick_limit }
            @transaction.save!(validate: false)
            @merchant.update_attributes!(:quick_limit => new_limit)
          else
            new_limit =  @merchant.balance_limit + @transaction.amount + @transaction.charges
            @change_limit = @merchant.change_limits.create!(amount: (@transaction.amount + @transaction.charges),
                                                                     distributor_mobile: @transaction.distributor_mobile,
                                                                     previous_limit: @merchant.balance_limit,
                                                                     current_limit: new_limit, source: 'transaction',
                                                                     action: 'add', note: @transaction.admin_remark,
                                                                     quick_request: false, status: 'Transaction')
            @transaction.attributes = { current_limit: new_limit, previous_limit: @merchant.balance_limit }
            @transaction.save!(validate: false)
            @merchant.update_attributes!(:balance_limit => new_limit)
          end
        end
        @transaction.attributes = { merchant_remark: params[:transaction][:merchant_remark],
                                    admin_remark: params[:transaction][:admin_remark],
                                    updated: true, status: status,
                                    admin_mobile: current_user.mobile
                                  }
        @transaction.save!(validate: false)
      else
        @transaction.attributes = { merchant_remark: params[:transaction][:merchant_remark],
                                    admin_remark: params[:transaction][:admin_remark], 
                                    admin_mobile: current_user.mobile
                                  }
        @transaction.save!(validate: false)       
      end
      message = { success: "Transaction successfully updated"}
      if @transaction.quick_transfer
        redirect_to quick_request_admin_senders_path,  flash: message
      else
        redirect_to admin_senders_path, flash: message
      end
    end
  rescue Exception => error
    redirect_to request.referrer, flash: { error:  "#{error}"}
  end

  def bulk_status_update
    transactions = Transaction.where('id IN (?) and status = "In Process"', params[:transaction_ids]).update_all(status: 'Done', admin_mobile: current_user.mobile)
    render json: { status: 200 }
  end

  def search
    if params[:quick_request] == 'true'
      quick_headers
    else
      headers
    end
    query = []
    distributor = User.find_by_mobile(params[:distributor_id]).try(:distributor)
    query << "transactions.created_at <= '#{params[:end].to_date.end_of_day}'" if params[:end].present?
    query << "transactions.created_at >= '#{params[:start].to_date.beginning_of_day}'" if params[:start].present?
    if params[:start].present? && params[:end].present?
      query = []
      query << "transactions.created_at BETWEEN '#{params[:start].to_date.beginning_of_day}' AND '#{params[:end].to_date.end_of_day}'"
    end
    query << "transactions.merchant_mobile = #{params[:merchant_id]}" if params[:merchant_id].present?
    query << "distributors.id = #{distributor.id}" if params[:distributor_id].present? && distributor.present?
    query << "(beneficiaries.account_number LIKE '%#{params[:search]}%' or transactions.txt_id LIKE '%#{params[:search]}%' or senders.name LIKE '%#{params[:search]}%' or senders.mobile LIKE '%#{params[:search]}%' or beneficiaries.name LIKE '%#{params[:search]}%' or beneficiaries.account_number LIKE '%#{params[:search]}%' or beneficiaries.ifsc_code LIKE '%#{params[:search]}%')"
    query << "transactions.status = '#{params[:status]}'" if params[:status].present?
    val = params[:quick_request] == 'true' ? 1 : 0
    query << "transactions.quick_transfer = '#{val}'"
    if distributor.present?
      @transactions = Transaction.joins([:beneficiary, :sender, merchant:[:distributor]])
                          .where(query.join(' AND ')).distinct.page(params[:page]).per(PER_PAGE).order(created_at: :desc)
    else
      @transactions = Transaction.joins([:beneficiary, :sender, :merchant])
                          .where(query.join(' AND ')).distinct.page(params[:page]).per(PER_PAGE).order(created_at: :desc)
    end
    if @transactions.present?
      if params[:quick_request] == 'true'
        render 'quick_request'
      else
        render 'index'
      end
    else
      if params[:quick_request] == 'true'
        render 'quick_request', flash: { error: 'No Data Found' }
      else
        render 'index', flash: { error: 'No Data Found' }
      end
    end
  end

  # def request_notification
  #   unread_view_requests = Notification.where(read_by_admin: false, quick_transfer: false).count
  #   unread_quick_requests = Notification.where(read_by_admin: false, quick_transfer: true).count
  #   render json: { unread_view_requests: unread_view_requests, unread_quick_requests: unread_quick_requests }
  # end

  def beneficiaries
    @sender = Sender.find_by_mobile(params[:mobile])
    beneficiaries = @sender.beneficiaries
    if beneficiaries.present?
      render json: { beneficiaries: beneficiaries, status: 200 }
    else
      render json: { status: 404 }
    end
  end

  def load_transactions
    @transactions = Transaction.includes([:sender, merchant: [:profile, :user,  distributor:[:profile, :user]], beneficiary: [:bank_detail]]).where(quick_transfer: false, hidden: false).page(params[:page]).per(PER_PAGE).order(created_at: :desc)
  end

  def destroy
    @transaction = Transaction.find(params[:id])
    ActiveRecord::Base.transaction do
      if @transaction.status == 'In Process' && !@transaction.updated
        @merchant = @transaction.merchant
        if @transaction.quick_transfer
          new_limit =  @merchant.quick_limit + @transaction.amount + @transaction.charges
          @change_limit = @merchant.change_limits.create!(amount: (@transaction.amount + @transaction.charges),
                                                                   distributor_mobile: @transaction.distributor_mobile,
                                                                   previous_limit: @merchant.quick_limit,
                                                                   current_limit: new_limit, source: 'transaction',
                                                                   action: 'add', note: @transaction.admin_remark, quick_request: true, status: 'Delete Transaction')
          @transaction.attributes = { current_limit: new_limit, previous_limit: @merchant.quick_limit }
          @transaction.save!(validate: false)
          @merchant.update_attributes!(:quick_limit => new_limit)
        else
          new_limit =  @merchant.balance_limit + @transaction.amount + @transaction.charges
          @change_limit = @merchant.change_limits.create!(amount: (@transaction.amount + @transaction.charges),
                                                                   distributor_mobile: @transaction.distributor_mobile,
                                                                   previous_limit: @merchant.balance_limit,
                                                                   current_limit: new_limit, source: 'transaction',
                                                                   action: 'add', note: @transaction.admin_remark, quick_request: false, status: 'Delete Transaction')
          @transaction.attributes = { current_limit: new_limit, previous_limit: @merchant.balance_limit }
          @transaction.save!(validate: false)
          @merchant.update_attributes!(:balance_limit => new_limit)
        end
        @transaction.attributes = { status: 'Delete Transaction', hidden: true, updated: true }
        @transaction.save!(validate: false)
      else
        @transaction.attributes = { hidden: true, updated: true }
        @transaction.save!(validate: false)
      end
      redirect_to request.referrer, flash: { success: "Transaction Removed successfully"}
    end
  rescue Exception => error
    redirect_to request.referrer, flash: { error:  "Transaction could not be completed, try again"}
  end

  def download_rbl_neft_csv
    @results = Transaction.includes([:beneficiary, :merchant]).where("quick_transfer = 0 and status NOT IN ('Delete Transaction', 'REJECT/RETURN')").order(created_at: :desc).first(2000)
    filename = "RBL-NEFT-Report.xls"
    respond_to do |format|
      format.xls do
        response.headers['Content-Type'] = 'application/vnd.ms-excel'
        response.headers['Content-Disposition'] = "attachment; filename=#{filename}"
      end
    end
  end

  def download_axis_neft_csv
    @results = Transaction.includes([:beneficiary, :merchant]).where("quick_transfer = 0 and status NOT IN ('Delete Transaction', 'REJECT/RETURN')").order(created_at: :desc).first(2000)
    filename = "AXIS-NEFT-Report.xls"
    respond_to do |format|
      format.xls do
        response.headers['Content-Type'] = 'application/vnd.ms-excel'
        response.headers['Content-Disposition'] = "attachment; filename=#{filename}"
      end
    end
  end

  def download_quick_csv
    @results = Transaction.includes([:beneficiary, :merchant]).where("quick_transfer = 1 AND downloaded = 0 and status IN('In Process', 'Done')").order(created_at: :desc)
    filename = "IMPS-Report.xls"
    respond_to do |format|
      format.xls do
        response.headers['Content-Type'] = 'application/vnd.ms-excel; charset=utf-8'
        response.headers['Content-Disposition'] = "attachment; filename=#{filename}"
      end
    end
  end

  def download_normal_csv
    @results = Transaction.includes([merchant:[:profile], beneficiary:[:bank_detail]]).where("quick_transfer = 0 and status NOT IN ('Delete Transaction', 'REJECT/RETURN')").order(created_at: :desc).first(2000)
    filename = "Self-Report.xls"
    respond_to do |format|
      format.xls do
        response.headers['Content-Type'] = 'application/vnd.ms-excel; charset=utf-8'
        response.headers['Content-Disposition'] = "attachment; filename=#{filename}"
      end
    end
  end

  def download_imps_self_report
    @results = Transaction.includes([merchant:[:profile], beneficiary:[:bank_detail]]).where("quick_transfer = 1 and status NOT IN ('Delete Transaction')").order(created_at: :desc).first(2000)
    filename = "Imps-Self-Report.xls"
    respond_to do |format|
      format.xls do
        response.headers['Content-Type'] = 'application/vnd.ms-excel; charset=utf-8'
        response.headers['Content-Disposition'] = "attachment; filename=#{filename}"
      end
    end
  end

  def update_imps
    trans = Transaction.where("quick_transfer = 1 AND downloaded = 0 and status IN('In Process', 'Done')").update_all(status: 'Done', updated: true, downloaded: true)
  end

  def headers
    query = []
    query << "created_at <= '#{params[:end].to_date.end_of_day}'" if params[:end].present?
    query << "created_at >= '#{params[:start].to_date.beginning_of_day}'" if params[:start].present?
    if params[:start].present? && params[:end].present?
      query = []
      query << "created_at BETWEEN '#{params[:start].to_date.beginning_of_day}' AND '#{params[:end].to_date.end_of_day}'"
    end
    query << "status IN ('Done', 'In Process') and quick_transfer =  0"
    transactions = Transaction.where(query.join(' AND '))
    @total_transactions = transactions.count
    @total_transfer = transactions.sum(:amount)
    @total_charges = transactions.sum(:charges)
  end

  def quick_headers
    query = []
    query << "created_at <= '#{params[:end].to_date.end_of_day}'" if params[:end].present?
    query << "created_at >= '#{params[:start].to_date.beginning_of_day}'" if params[:start].present?
    if params[:start].present? && params[:end].present?
      query = []
      query << "created_at BETWEEN '#{params[:start].to_date.beginning_of_day}' AND '#{params[:end].to_date.end_of_day}'"
    end
    query << "status = 'Done' and quick_transfer =  1"
    transactions = Transaction.where(query.join(' AND '))
    @total_transactions = transactions.count
    @total_transfer = transactions.sum(:amount)
    @total_charges = transactions.sum(:charges)
  end

  def bank_detail
    @bank_detail = BankDetail.new
  end

  def update_bank_detail
    bank_detail = BankDetail.find_by_ifsc_code(params[:bank_detail][:ifsc_code]) || BankDetail.new
    bank_detail.attributes = bank_params
    bank_detail.save
    redirect_to admin_senders_bank_detail_path, flash: { success: 'BankDetail successfully updated' }
  end

  def bank_params
    params.require(:bank_detail).permit!
  end
end
