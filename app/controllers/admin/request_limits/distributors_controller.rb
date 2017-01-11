class Admin::RequestLimits::DistributorsController < ApplicationController
  include Permissions::RequestLimits::Distributor
  PER_PAGE = 10
  before_action :authenticate_user!
  before_action :distributor_limit_request_view_check, only: [:index]
  before_action :distributor_limit_request_edit_check, only: [:edit]
  before_action :distributor_limit_request_update_check, only: [:update]
  before_action :distributor_limit_request_delete_check, only: [:destroy]

  def index
    # RequestLimit.where(requestable_type: 'Distributor').update_all(read_by_admin: true)
    load_request_limits
  end

  def edit
    @request_limit ||= RequestLimit.find(params[:id])
    if @request_limit.updated
      if  !request.referrer.nil?
        redirect_to request.referrer, flash:{ error:  'Already Updated' } 
      else
        redirect_to admin_request_limits_distributors_path, flash: { error:  'Already Updated' }
      end
    end       
    @distributor = Distributor.find(@request_limit.requestable_id)       
    # load_distributor
  end

  def load_request_limits
    @dist_id = []
    Distributor.all.each do |dist_id|
      @dist_id << dist_id.id
    end
    @request_limits = RequestLimit.where('hidden = 0 and requestable_id IN (?) and requestable_type= (?) and status="On Hold"', @dist_id, 'Distributor').page(params[:page]).per(PER_PAGE).order(created_at: :desc)
  end

  def search
    if params[:status].present?
      status= params[:status]
      hidden = ''
    else
      status= 'On Hold'
      hidden = 0
    end
    users = User.joins(distributor: [:profile]).where("users.mobile LIKE ? or profiles.first_name LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    user_ids = []
    users.each do |user|
      user_ids << user.id
    end
    distributors = Distributor.where('user_id IN (?)', user_ids)
    dist_ids = []
    distributors.each do |distributor|
      dist_ids << distributor.id
    end 
    @request_limits = RequestLimit.where('hidden = ? and requestable_id IN (?) and requestable_type= (?) and status=?', hidden, dist_ids, 'Distributor', status).page(params[:page]).per(PER_PAGE).order(created_at: :desc)
    if @request_limits.present?
      render 'index'
    else
      render 'index',  flash: { error: 'No data found'}
    end
  end

  def show
    load_distributor
  end

  def update
    load_distributor
    ActiveRecord::Base.transaction do
      if update_params[:status] == 'Approve'
        new_limit =  @distributor.balance_limit.to_i + @request_limit.amount.to_i
        change_limit = @distributor.change_limits.create!(amount: @request_limit.amount,
                                                       note: params[:remark],
                                                       previous_limit: @distributor.balance_limit,
                                                       current_limit: new_limit, source: 'admin',
                                                       action: 'add', status: 'Approve')
        @request_limit.update_attributes!(update_params)
        unless current_user.has_role?('super_admin')
          admin_cl = current_user.admin.change_limits.create!(amount: @request_limit.amount,
                                                  previous_limit: current_user.admin.balance_limit,
                                                  current_limit:  current_user.admin.balance_limit - @request_limit.amount,
                                                  source: 'self', action: 'less', status: 'Approve')
          current_user.admin.update!(balance_limit: admin_cl.current_limit)
        end
        @distributor.update!(:balance_limit => new_limit)
        redirect_to admin_request_limits_distributors_path, flash:{ success: 'Limit Updated' }
      else
        @request_limit.update_attributes!(update_params)
        redirect_to admin_request_limits_distributors_path
      end
    end
    @request_limit.update(updated:true)
  rescue Exception => error
    redirect_to request.referrer , flash:{ error: 'Error Updating the LIMIT Request, Try Again' }        
  end

  def destroy
    request_limit = RequestLimit.find(params[:id])
    if request_limit.update(hidden: true)
      redirect_to request.referrer
    else
      redirect_to request.referrer, flash: { error: request_limit.error}
    end
  end

  def request_notification
    unread_requests = RequestLimit.where(read_by_admin: false, requestable_type: 'Distributor').count
    render json: { unread_requests: unread_requests }
  end

  def load_distributor
    @request_limit ||= RequestLimit.find(params[:id])
    @distributor = Distributor.find(@request_limit.requestable_id)
  end

  def update_params
    params.require(:request_limit).permit(:status, :remark)
  end
end
