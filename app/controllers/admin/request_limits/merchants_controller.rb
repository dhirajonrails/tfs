class Admin::RequestLimits::MerchantsController < ApplicationController
  include Permissions::RequestLimits::Merchant
  PER_PAGE = 10
  before_action :authenticate_user!
  before_action :merchant_limit_request_view_check, only: [:index]
  before_action :merchant_limit_request_edit_check, only: [:edit]
  before_action :merchant_limit_request_update_check, only: [:update]
  before_action :merchant_limit_request_delete_check, only: [:destroy]

  def index
    # RequestLimit.where(requestable_type: 'Merchant').update_all(read_by_admin: true)
    load_request_limits
  end

  def edit
    @request_limit ||= RequestLimit.find(params[:id])
    if @request_limit.updated
      if  !request.referrer.nil?
        redirect_to request.referrer, flash:{ error:  'Already Updated' } 
      else
        redirect_to admin_request_limits_merchants_path, flash: { error:  'Already Updated' }
      end
    end              
    load_merchant
  end

  def load_request_limits
    @request_limits = RequestLimit.where('hidden = 0 and requestable_type= (?) and status="On Hold"', 'Merchant').page(params[:page]).per(PER_PAGE).order(created_at: :desc)
  end

  def show
    load_merchant
  end

  def update
    load_merchant
    ActiveRecord::Base.transaction do
      @distributor = @merchant.distributor
      if update_params[:status] == 'Approve'
        if @request_limit.quick_request
          new_merchant_limit =  @merchant.quick_limit + @request_limit.amount
          unless current_user.has_role?('super_admin')
            admin_cl = current_user.admin.change_limits.create!(amount: @request_limit.amount,
                                                    previous_limit: current_user.admin.balance_limit,
                                                    current_limit:  current_user.admin.balance_limit - @request_limit.amount,
                                                    source: 'self', action: 'less', status: 'Approve',  quick_request: true)
            current_user.admin.update!(balance_limit: admin_cl.current_limit)
          end
          change_merchant_limit = @merchant.change_limits.create!(amount: @request_limit.amount,
                                                         note: params[:remark],
                                                         previous_limit: @merchant.quick_limit,
                                                         current_limit: new_merchant_limit, source: 'admin',
                                                         action: 'add', quick_request: true, status: 'Approve')
          if @distributor.present?
            new_distributor_limit = @distributor.balance_limit - @request_limit.amount
            change_distributor_limit = @distributor.change_limits.create!(amount: @request_limit.amount,
                                                           note: params[:remark],
                                                           previous_limit: @distributor.balance_limit,
                                                           current_limit: new_distributor_limit, source: 'admin',
                                                           action: 'less', status: 'Approve')
            @distributor.update!(:balance_limit => new_distributor_limit)
            change_merchant_limit.update_attributes!(distributor_mobile: @distributor.mobile)
          end
          @request_limit.update_attributes!(update_params)
          @merchant.update!(:quick_limit => new_merchant_limit)
          redirect_to admin_request_limits_merchants_path, flash:{ success: "Limit Approved" }
        else
          unless current_user.has_role?('super_admin')
            admin_cl = current_user.admin.change_limits.create!(amount: @request_limit.amount,
                                                    previous_limit: current_user.admin.balance_limit,
                                                    current_limit:  current_user.admin.balance_limit - @request_limit.amount,
                                                    source: 'self', action: 'less', status: 'Approve',  quick_request: false)
            current_user.admin.update!(balance_limit: admin_cl.current_limit)        
          end
          new_merchant_limit =  @merchant.balance_limit + @request_limit.amount
          change_merchant_limit = @merchant.change_limits.create!(amount: @request_limit.amount,
                                                         note: params[:remark],
                                                         previous_limit: @merchant.balance_limit,
                                                         current_limit: new_merchant_limit, source: 'admin',
                                                         action: 'add', quick_request: false, status: 'Approve')
          if @distributor.present?
            new_distributor_limit = @distributor.balance_limit - @request_limit.amount
            change_distributor_limit = @distributor.change_limits.create!(amount: @request_limit.amount,
                                                           note: params[:remark],
                                                           previous_limit: @distributor.balance_limit,
                                                           current_limit: new_distributor_limit, source: 'admin',
                                                           action: 'less', status: 'Approve')
            @distributor.update!(:balance_limit => new_distributor_limit)
            change_merchant_limit.update_attributes!(distributor_mobile: @distributor.mobile)
          end
          @request_limit.update_attributes!(update_params)
          @merchant.update!(:balance_limit => new_merchant_limit)
          redirect_to admin_request_limits_merchants_path, flash:{ success: "Limit Approved" }
        end
      else
        @request_limit.update_attributes!(update_params)
        redirect_to admin_request_limits_merchants_path, flash:{ success: "Limit #{update_params[:status]}" }
      end
    end
    @request_limit.update(updated:true)  
  rescue Exception => error
    redirect_to request.referrer , flash:{ error: 'Error Updating the LIMIT Request, Check the limits and balances' }
  end

  def search
    quick = nil
    if params[:request].present?
      if params[:request] == 'Quick'
        quick = 1
      else
        quick = 0
      end
    end                
    if params[:status].present?
      status= params[:status]
      hidden = ''
    else
      status= 'On Hold'
      hidden = 0
    end
    users = User.joins(merchant: [:profile]).where("users.mobile LIKE ? or profiles.first_name LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    distributors = User.joins(distributor: [:profile]).where("users.mobile LIKE ? or profiles.first_name LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    (users << distributors).flatten!
    user_ids = []
    users.map do |user|
      user_ids << user.id
    end
    distributors.map do |user|
      user_ids << user.distributor.id
    end
    merchants = Merchant.where('user_id IN (?) or distributor_id IN (?)', user_ids, user_ids)
    mer_ids = []
    merchants.each do |merchant|
      mer_ids << merchant.id
    end
    unless quick.nil?
      @request_limits = RequestLimit.where('quick_request = ? and hidden = ? and requestable_id IN (?) and requestable_type= (?) and status=?',quick, hidden, mer_ids, 'Merchant', status).page(params[:page]).per(PER_PAGE).order(created_at: :desc)
    else
      @request_limits = RequestLimit.where('hidden = ? and requestable_id IN (?) and requestable_type= (?) and status=?',hidden, mer_ids, 'Merchant', status).page(params[:page]).per(PER_PAGE).order(created_at: :desc)
    end
    render 'index'
  end

  def destroy
    request_limit = RequestLimit.find(params[:id])
    if request_limit.update(hidden: true)
      redirect_to request.referrer
    else
      redirect_to request.referrer, flash: { error: request_limit.error}
    end
  end

  def load_merchant
    @request_limit ||= RequestLimit.find(params[:id])
    @merchant = Merchant.find(@request_limit.requestable_id)
  end

  def update_params
    params.require(:request_limit).permit(:status, :remark)
  end

  def request_notification
    unread_requests = RequestLimit.where(read_by_admin: false, requestable_type: 'Merchant').count
    render json: { unread_requests: unread_requests }
  end
end
