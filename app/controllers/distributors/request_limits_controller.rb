class Distributors::RequestLimitsController < ApplicationController
  PER_PAGE = 10
  before_action :authenticate_user!, :is_distributor?
  before_filter :distributor, only: [:new, :create, :build_request_limit, :load_request_limits, :update ]

  def index
    load_request_limits
  end

  def new
    @request_limit = @distributor.request_limits.build
  end

  def create
    build_request_limit
    if @request_limit.save
      @request_limit.update(status: 'On Hold', hidden: false, updated: false)
      redirect_to distributors_request_limits_path, flash: { success: 'Limit Request Successfully Sent'}
    else
      render 'new', flash: { success: 'There was some error requesting limit'}
    end
  end
  
  def edit
    load_merchant
  end

  def show
    load_merchant
  end

  def update
    load_merchant
    ActiveRecord::Base.transaction do
      if update_params[:status] == 'Approve'
        if @request_limit.quick_request
          new_merchant_limit =  @merchant.quick_limit + @request_limit.amount
          change_merchant_limit = @merchant.change_limits.create!(amount: @request_limit.amount,
                                                         note: params[:remark],
                                                         previous_limit: @merchant.quick_limit,
                                                         current_limit: new_merchant_limit, source: 'distributor',
                                                         action: 'add', quick_request: true, status: 'Approve')
          new_distributor_limit = @distributor.balance_limit - @request_limit.amount
          change_distributor_limit = @distributor.change_limits.create!(amount: @request_limit.amount,
                                                         note: params[:remark],
                                                         previous_limit: @distributor.balance_limit,
                                                         current_limit: new_distributor_limit, source: 'distributor',
                                                         action: 'less', status: 'Approve')
          @request_limit.update_attributes!(update_params)
          @merchant.update!(:quick_limit => new_merchant_limit)
          @distributor.update!(:balance_limit => new_distributor_limit)
          redirect_to merchant_requests_distributors_request_limits_path, flash:{ success: "Limit Approved" }
        else
          new_merchant_limit =  @merchant.balance_limit + @request_limit.amount
          change_merchant_limit = @merchant.change_limits.create!(amount: @request_limit.amount,
                                                         note: params[:remark],
                                                         previous_limit: @merchant.balance_limit,
                                                         current_limit: new_merchant_limit, source: 'distributor',
                                                         action: 'add',quick_request: false, status: 'Approve')
          new_distributor_limit = @distributor.balance_limit - @request_limit.amount
          change_distributor_limit = @distributor.change_limits.create!(amount: @request_limit.amount,
                                                         note: params[:remark],
                                                         previous_limit: @distributor.balance_limit,
                                                         current_limit: new_distributor_limit, source: 'distributor',
                                                         action: 'less', status: 'Approve')
          @request_limit.update_attributes!(update_params)
          @merchant.update!(:balance_limit => new_merchant_limit)
          @distributor.update!(:balance_limit => new_distributor_limit)
          redirect_to merchant_requests_distributors_request_limits_path, flash:{ success: "Limit Approved" } 
        end
        change_merchant_limit.update_attributes!(distributor_mobile: current_user.mobile)           
      else
        @request_limit.update_attributes!(update_params)
        redirect_to merchant_requests_distributors_request_limits_path, flash:{ success: "Limit #{update_params[:status]}" }
      end
    end
    @request_limit.update(updated:true)  
  rescue Exception => error
    redirect_to request.referrer , flash:{ error: "#{error}" }
  end

  def load_merchant
    @request_limit ||= RequestLimit.find(params[:id])
    @merchant = Merchant.find(@request_limit.requestable_id)
  end

  def search
    @request_limits = current_user.distributor.request_limits.where(status: "#{params[:status]}").page(params[:page]).per(PER_PAGE).order(created_at: :desc)
    if @request_limits.present?
      render 'index'
    else
      render 'index', flash: { error: 'no Data found' }
    end
  end

  def search_merchant_requests
    query = []
    query << "quick_request = #{params[:request]}" if params[:request].present?
    query << "status = '#{params[:status]}'" if params[:status].present?
    users = User.joins(merchant: [:profile]).where("users.mobile LIKE ? or profiles.first_name LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    user_ids = []
    users.map do |user|
      user_ids << user.id
    end
    dist_id = current_user.distributor.id
    merchants = Merchant.where('user_id IN (?) and distributor_id = ?', user_ids, dist_id)
    mer_ids = []
    merchants.each do |merchant|
      mer_ids << merchant.id
    end
    query << "requestable_id IN (#{mer_ids.join(',')}) and requestable_type='Merchant'"
    @request_limits = RequestLimit.where(query.join(' AND ')).page(params[:page]).per(PER_PAGE).order(created_at: :desc)
    if @request_limits.present?
      render 'merchant_requests'
    else
      render 'merchant_requests', flash: { error: 'No data found'}
    end
  end

  def merchant_requests
    load_request_history
  end

  def request_notification
    @mer_id = merchant_ids
    unread_requests = RequestLimit.where('requestable_id IN (?) and requestable_type= (?)', @mer_id, 'Merchant').count
    render json: { unread_requests: unread_requests }
  end

  def load_request_limits
    @request_limits = current_user.distributor.request_limits.where(status: 'On Hold').page(params[:page]).per(PER_PAGE).order(created_at: :desc)
  end

  def load_request_history
    @request_limits = RequestLimit.where('distributor_mobile= (?) and status= "On Hold"', current_user.mobile).page(params[:page]).per(PER_PAGE).order(created_at: :desc)
  end

  def merchant_ids
    @merchants = current_user.distributor.merchants
    mer_id = []
    @merchants.each do |merchant|
      mer_id << merchant.id
    end
    mer_id
  end

  def request_limit_params
    params.require(:request_limit).permit(:amount, :bank, :tracking_id)
  end

  def build_request_limit
    @request_limit ||= @distributor.request_limits.build
    @request_limit.attributes = request_limit_params     
  end

  def update_params
    params.require(:request_limit).permit(:status, :remark)
  end

  def distributor
    @distributor = current_user.distributor
  end
end
