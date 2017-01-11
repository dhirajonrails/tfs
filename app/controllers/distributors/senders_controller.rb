class Distributors::SendersController < ApplicationController
  before_action :authenticate_user!, :is_distributor?, :build_distributor
  PER_PAGE = 10

  def index
    add = @distributor.change_limits.where(action:'add').sum(:amount)
    less = @distributor.change_limits.where(action:'less').sum(:amount)
    @total_limit = add - less
    # ids = load_ids
    # @stat_transaction = Transaction.where('beneficiary_id IN (?) AND status=(?)', ids, 'Done')
    # @distributor.notifications.update_all(read_by_distributor: true)
    load_transactions
  end

  def search
    # add = @distributor.change_limits.where(action:'add').sum(:amount)
    # less = @distributor.change_limits.where(action:'less').sum(:amount)
    # @total_limit = add - less
    # ids = load_ids
    # @stat_transaction = Transaction.where('beneficiary_id IN (?) AND status=(?)', ids, 'Done')
    query = []
    merchant = User.find_by_mobile(params[:merchant_id]).try(:merchant)
    search_distributor = merchant.try(:distributor)
    query << "created_at <= '#{params[:end].to_date.end_of_day}'" if params[:end].present?
    query << "created_at >= '#{params[:start].to_date.beginning_of_day}'" if params[:start].present?
    if params[:start].present? && params[:end].present?
      query = []
      query << "created_at BETWEEN '#{params[:start].to_date.beginning_of_day}' AND '#{params[:end].to_date.end_of_day}'"
    end
    query << "txt_id = '#{params[:txn_id]}'" if params[:txn_id].present?
    query << "status = '#{params[:status]}'" if params[:status].present?
    query << "quick_transfer = #{params[:request]}" if params[:request].present?
    if params[:merchant_id].present?
      if !search_distributor.nil? && search_distributor.id == @distributor.id
        ben_id = []
        trans_id = []
        merchant.senders.each do |send|
          ben_id << send.id
        end
        beneficiaries = Beneficiary.where('sender_id IN (?) ', ben_id)
        beneficiaries.each do |ben|
          trans_id << ben.id
        end
        trans_id = trans_id.to_s
        trans_id.chop!.slice!(0)
        query << "beneficiary_id IN (#{trans_id})"
        @transactions = Transaction.where(query.join(' AND ')).page(params[:page]).per(PER_PAGE).order(created_at: :desc)
      else
        @transactions = ''
      end
    else
      @transactions = Transaction.where(query.join(' AND ')).page(params[:page]).per(PER_PAGE).order(created_at: :desc)
    end
    if @transactions.present?
      render 'index'
    else
      render 'index', flash: { error: 'No data found'}
    end
  end

  def beneficiaries
    @sender = Sender.find_by_mobile(params[:mobile])
    beneficiaries = @sender.beneficiaries
    if beneficiaries.present?
      render json: { beneficiaries: beneficiaries, status: 200 }
    else
      render json: { status: 404 }
    end    
  end

  def request_notification
    unread_requests = @distributor.notifications.where(read_by_distributor: false).count
    render json: { unread_requests: unread_requests }
  end

  def load_transactions
    @transactions = Transaction.includes([:sender, :merchant, beneficiary: [:bank_detail]]).where("distributor_mobile = #{current_user.mobile}").distinct.page(params[:page]).per(PER_PAGE).order(created_at: :desc)
  end
  
  def load_ids
    mer_id = []
    ben_id = []
    trans_id = []
    merchants = @distributor.try(:merchants)
    merchants.each do |mer|
      mer_id << mer.id
    end
    senders = Sender.where('merchant_id IN (?) ', mer_id)  
    senders.each do |send|
      ben_id << send.id
    end
    beneficiaries = Beneficiary.where('sender_id IN (?) ', ben_id)
    beneficiaries.each do |ben|
      trans_id << ben.id
    end
    trans_id
  end

  def build_distributor
    @distributor = current_user.distributor
  end
end
