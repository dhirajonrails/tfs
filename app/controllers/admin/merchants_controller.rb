class Admin::MerchantsController < ApplicationController
  include Permissions::MerchantPermissions

  PER_PAGE = 10
  before_action :authenticate_user!
  before_action :merchant_index_check, only: [:index]
  before_action :merchant_new_check, only: [:new, :create]
  before_action :merchant_edit_check, only: [:edit]
  before_action :merchant_update_check, only: [:update]
  before_action :merchant_add_limit_check, only: [:add_limit, :create_add_limit]
  before_action :merchant_less_limit_check, only: [:less_limit, :create_less_limit]
  before_action :merchant_view_limit_check, only: [:view_limit]
  before_action :merchant_limit_history_check, only: [:limit_history]

  def index
    load_merchants
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  def new
    @user = User.new
    @merchant = @user.build_merchant
    @profile = @merchant.build_profile
  end

  def create
    user = User.new(merchant_params)
    if user.save_with_merchant
      merchant = Merchant.find(user.merchant.id)
      dist_mobile = merchant.distributor.mobile rescue nil
      merchant.source = 'admin'
      merchant.mobile = user.mobile
      merchant.save
      merchant.change_limits.create!(amount: 100000, previous_limit: 0, current_limit: 100000, source: 'admin',
                          action: 'add', note: 'Created Merchant', quick_request: false, status: 'Done',
                          distributor_mobile: dist_mobile)        
      redirect_to admin_merchant_path(id: merchant.id), flash:{ success: 'Merchant Successfully Created' }
    else 
      redirect_to new_admin_merchant_path, flash:{ error: user.errors }
    end 
  end

  def edit
    @user = Merchant.find(params[:id]).user
  end

  def update
    @user = User.find(params[:id])
    distributor_id = @user.merchant.distributor_id
    @user.attributes = merchant_params
    ActiveRecord::Base.transaction do
      @user.save!(validate: false)
      if distributor_id != @user.merchant.distributor_id
        dist_mobile =  @user.merchant.distributor.mobile
        pending_requests = @user.merchant.request_limits.where(status: 'On Hold')
        pending_requests.update_all(distributor_mobile: dist_mobile)
      end
      redirect_to admin_merchants_path
    end
  rescue Exception => error
    Rails.logger.info error
    redirect_to request.referrer, flash:{ error: 'Merchant cannot be updated, check the fields' }
  end

  def show
    load_merchant
  end

  def limit_history
    load_limit_history
  end

  def load_merchant
    @merchant = Merchant.find(params[:id])
  end

  def save_merchant
    if @merchant.save
      redirect_to admin_merchants_path
    end
  end

  def search
    @merchant = User.find_by_mobile(params[:mobile_number]).try(:merchant)
    if @merchant.present?
      render json: { merchant: @merchant, profile: @merchant.profile, status: 200 } 
    else
      render json: { status: 404 }
    end
  end
  
  def search_merchant
    users = User.joins(merchant: [:profile], ).where("users.mobile LIKE ? or profiles.first_name LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    distributors = User.joins(distributor: [:profile]).where("users.mobile LIKE ? or profiles.first_name LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    user_ids = []
    users.map do |user|
      user_ids << user.id
    end
    distributors.map do |user|
      user_ids << user.distributor.id
    end
    @merchants = Merchant.joins([:user, :profile]).where('user_id IN (?) or distributor_id IN (?)', user_ids, user_ids).page(params[:page]).per(PER_PAGE).order(created_at: :desc)
    if @merchants.present?
      render 'index'
    else
      render 'index', flash: { error: 'No data found'}
    end
  end

  def search_limit
    users = User.joins(merchant: [:profile]).where("users.mobile LIKE ? or profiles.first_name LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    distributors = User.joins(distributor: [:profile]).where("users.mobile LIKE ? or profiles.first_name LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    # (users << distributors).flatten!
    user_ids = []
    distributors.map do |user|
      user_ids << user.distributor.id
    end
    users.map do |user|
      user_ids << user.id
    end
    @merchants = Merchant.where('user_id IN (?) or distributor_id IN (?)', user_ids, user_ids).page(params[:page]).per(PER_PAGE).order(created_at: :desc)
    if @merchants.present?
      render 'view_limit'
    else
      render 'view_limit', flash: { error: 'No data found'}
    end
  end

  def search_limit_history
    query = []
    query << "quick_request = #{params[:request]}" if params[:request].present?
    query << "status = '#{params[:status]}'" if params[:status].present?
    users = User.joins(merchant: [:profile]).where("users.mobile LIKE ? or profiles.first_name LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    distributors = User.joins(distributor: [:profile]).where("users.mobile LIKE ? or profiles.first_name LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    (users << distributors).flatten!
    user_ids = []
    users.map do |user|
      user_ids << user.id
    end
    merchants = Merchant.where('user_id IN (?) or distributor_id IN (?)', user_ids, user_ids)
    mer_ids = []
    merchants.each do |merchant|
      mer_ids << merchant.id
    end
    query << "changable_id IN (#{mer_ids.join(',')}) and changable_type='Merchant'"
    @limit_history = ChangeLimit.where(query.join(' AND ')).page(params[:page]).per(PER_PAGE).order(created_at: :desc)              
    if @limit_history.present?
      render 'limit_history'
    else
      render 'limit_history', flash: { error: 'No data found'}
    end
  end

  def create_add_limit
    ActiveRecord::Base.transaction do
      merchant = User.find_by_mobile(params[:mobile]).merchant
      @distributor = merchant.distributor
      change_limit = merchant.change_limits.create!(change_limit_params)
      if change_limit.quick_request
        unless current_user.has_role?('super_admin')
          admin_cl = current_user.admin.change_limits.create!(amount: change_limit.amount,
                                                  previous_limit: current_user.admin.balance_limit,
                                                  current_limit:  current_user.admin.balance_limit - change_limit.amount,
                                                  source: 'self', action: 'less', status: 'Done',  quick_request: true)
          current_user.admin.update!(balance_limit: admin_cl.current_limit)
        end
        new_limit =  merchant.quick_limit + change_limit.amount
        change_limit.update_attributes!(previous_limit: merchant.quick_limit,
                                        current_limit: new_limit, source: 'admin',
                                        action: 'add', status: 'Done', quick_request: true)
        merchant.update!(quick_limit: new_limit)
        if @distributor.present?
          new_distributor_limit = @distributor.balance_limit - change_limit.amount
          change_distributor_limit = @distributor.change_limits.create!(amount: change_limit.amount,
                                                         note: params[:remark],
                                                         previous_limit: @distributor.balance_limit,
                                                         current_limit: new_distributor_limit, source: 'admin',
                                                         action: 'less', status: 'Done')
          @distributor.update!(:balance_limit => new_distributor_limit)
          change_limit.update_attributes!(distributor_mobile: @distributor.mobile)
        end
      else
        unless current_user.has_role?('super_admin')
          admin_cl = current_user.admin.change_limits.create!(amount: change_limit.amount,
                                                  previous_limit: current_user.admin.balance_limit,
                                                  current_limit:  current_user.admin.balance_limit - change_limit.amount,
                                                  source: 'self', action: 'less', status: 'Done',  quick_request: false)
          current_user.admin.update!(balance_limit: admin_cl.current_limit)
        end
        new_limit =  merchant.balance_limit + change_limit.amount
        change_limit.update_attributes!(previous_limit: merchant.balance_limit,
                                        current_limit: new_limit, source: 'admin',
                                        action: 'add', status: 'Done', quick_request: false)
        merchant.update!(balance_limit: new_limit)
        if @distributor.present?
          new_distributor_limit = @distributor.balance_limit - change_limit.amount
          change_distributor_limit = @distributor.change_limits.create!(amount: change_limit.amount,
                                                         note: params[:remark],
                                                         previous_limit: @distributor.balance_limit,
                                                         current_limit: new_distributor_limit, source: 'admin',
                                                         action: 'less', status: 'Done')
          @distributor.update!(:balance_limit => new_distributor_limit)                
          change_limit.update_attributes!(distributor_mobile: @distributor.mobile)
        end
      end
      redirect_to admin_merchants_limit_history_path
    end
  rescue Exception => error
    Rails.logger.info error
    redirect_to request.referrer, flash: { error:  "#{error}"}
  end

  def create_less_limit
    ActiveRecord::Base.transaction do
      merchant = User.find_by_mobile(params[:mobile]).merchant
      dist_mobile = merchant.distributor.mobile rescue nil
      change_limit = merchant.change_limits.create!(change_limit_params)
      if change_limit.quick_request
        new_limit =  merchant.quick_limit - change_limit.amount
        change_limit.update_attributes!(previous_limit: merchant.quick_limit,
                                        current_limit: new_limit, source: 'admin',
                                        action: 'less', status: 'Done', quick_request: true)
        merchant.update!(:quick_limit => new_limit)
        unless current_user.has_role?('super_admin')
          admin_cl = current_user.admin.change_limits.create!(amount: change_limit.amount,
                                                  previous_limit: current_user.admin.balance_limit,
                                                  current_limit:  current_user.admin.balance_limit + change_limit.amount,
                                                  source: 'self', action: 'add', status: 'Done',  quick_request: true)
          current_user.admin.update!(balance_limit: admin_cl.current_limit)
        end
      else
        new_limit =  merchant.balance_limit - change_limit.amount
        change_limit.update_attributes!(previous_limit: merchant.balance_limit,
                                        current_limit: new_limit, source: 'admin',
                                        action: 'less', status: 'Done', quick_request: false)
        merchant.update!(:balance_limit => new_limit)
        unless current_user.has_role?('super_admin')
          admin_cl = current_user.admin.change_limits.create!(amount: change_limit.amount,
                                                  previous_limit: current_user.admin.balance_limit,
                                                  current_limit:  current_user.admin.balance_limit + change_limit.amount,
                                                  source: 'self', action: 'add', status: 'Done',  quick_request: false)
          current_user.admin.update!(balance_limit: admin_cl.current_limit)
        end
      end        
      change_limit.update_attributes!(distributor_mobile: dist_mobile)
      redirect_to admin_merchants_limit_history_path
    end
  rescue Exception => error
    Rails.logger.info error
    render 'less_limit' , flash:{ error: "#{error}" }
  end
  
  def view_limit
    load_merchants
    filename = "#{Time.now.strftime('%d%m')}-Merchant_limit.xls"
    respond_to do |format|
      format.html
      format.xls do
        response.headers['Content-Type'] = 'application/excel'
        response.headers['Content-Disposition'] = "attachment; filename=#{filename}"
      end
    end      
  end

  def download_view_limit
    @merchants = Merchant.all
    filename = "#{Time.now.strftime('%d%m')}-Merchant_limit.xls"
    respond_to do |format|
      format.xls do
        response.headers['Content-Type'] = 'application/excel'
        response.headers['Content-Disposition'] = "attachment; filename=#{filename}"
      end
    end      
  end

  def load_merchants
    @merchants = Merchant.page(params[:page]).per(PER_PAGE).order(created_at: :desc)
  end

  def load_limit_history
    @limit_history = ChangeLimit.where(changable_type: 'Merchant').page(params[:page]).per(PER_PAGE).order(created_at: :desc)
  end

  def download_limit_history
    date = 60.days.ago
    @limit_history = ChangeLimit.where("changable_type = 'Merchant' and created_at> '#{date.strftime("%d-%m-%Y").to_date.beginning_of_day}' and status!='Transaction'").order(created_at: :desc)
    filename = "Merchant-limit-history.xls"
    respond_to do |format|
      format.xls do
        response.headers['Content-Type'] = 'application/vnd.ms-excel; charset=utf-8'
        response.headers['Content-Disposition'] = "attachment; filename=#{filename}"
      end
    end      
  end

  def logs
    @merchant_limit_history = ChangeLimit.where(changable_type: 'Merchant').order(created_at: :desc).page(params[:page]).per(25)
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def merchant_params
    params.require(:user).permit!
  end

  def change_limit_params
    params.require(:change_limit).permit(:amount, :note, :quick_request)
  end
end
