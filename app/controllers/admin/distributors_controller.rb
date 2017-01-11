class Admin::DistributorsController < ApplicationController
  include Permissions::DistributorPermissions
  PER_PAGE = 10
  before_action :authenticate_user!
  before_action :distributor_index_check, only: [:index]
  before_action :distributor_new_check, only: [:new, :create]
  before_action :distributor_edit_check, only: [:edit]
  before_action :distributor_update_check, only: [:update]
  before_action :distributor_add_limit_check, only: [:add_limit, :create_add_limit]
  before_action :distributor_less_limit_check, only: [:less_limit, :create_less_limit]
  before_action :distributor_view_limit_check, only: [:view_limit]
  before_action :distributor_limit_history_check, only: [:limit_history]

  def index
    load_distributors
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  def new
    @user = User.new
    @distributor = @user.build_distributor
    @profile = @distributor.build_profile
  end

  def create
    user = User.new(distributor_params)
    if user.save_with_distributor
      user.distributor.update(mobile: user.mobile)
      redirect_to admin_distributor_path(id: user.distributor.id), flash:{ success: 'Distributor Successfully Created' }
    else 
      redirect_to new_admin_distributor_path, flash:{ error: user.errors }
    end 
  end

  def edit
    @user = Distributor.find(params[:id]).user
  end

  def update
    @user = User.find(params[:id])
    @user.attributes = distributor_params
    ActiveRecord::Base.transaction do
      @user.save!(validate: false)
      redirect_to admin_distributors_path
    end
  rescue Exception => error
    Rails.logger.info error
    redirect_to request.referrer, flash:{ error: 'Distributor cannot be updated, check the fields' }
  end

  def search_distributor
    users = User.joins(distributor: [:profile]).where("users.mobile LIKE ? or profiles.first_name LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    user_ids = []
    users.each do |user|
      user_ids << user.id
    end
    @distributors = Distributor.where('user_id IN (?)', user_ids).page(params[:page]).per(PER_PAGE).order(created_at: :desc)
    if @distributors.present?
      render 'index'
    else
      render 'index', flash: { error: 'No data found'}
    end
  end

  def search_limit
    users = User.joins(distributor: [:profile]).where("users.mobile LIKE ? or profiles.first_name LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    user_ids = []
    users.each do |user|
      user_ids << user.id
    end
    @distributors = Distributor.where('user_id IN (?)', user_ids).page(params[:page]).per(PER_PAGE).order(created_at: :desc)
    if @distributors.present?
      render 'view_limit'
    else
      render 'view_limit', flash: { error: 'No data found'}
    end
  end

  def search_limit_history
    query = []
    query << "quick_request = #{params[:request]}" if params[:request].present?
    query << "status = '#{params[:status]}'" if params[:status].present?
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
    query << "changable_id IN (#{dist_ids.join(',')}) and changable_type='Distributor'"
    @limit_history = ChangeLimit.where(query.join(' AND ')).page(params[:page]).per(PER_PAGE).order(created_at: :desc)              
    if @limit_history.present?
      render 'limit_history'
    else
      render 'limit_history', flash: { error: 'No data found'}
    end
  end

  def limit_history
    load_limit_history
  end

  def show
    load_distributor
  end

  def load_distributor
    @distributor = Distributor.find(params[:id])
  end

  def save_distributor
    if @distributor.save
      redirect_to admin_distributors_path
    end
  end

  def search
    @distributor = User.find_by_mobile(params[:mobile_number]).try(:distributor)
    if @distributor.present?
      render json: { distributor: @distributor, profile: @distributor.profile, status: 200 } 
    else
      render json: { status: 404 }
    end
  end

  def create_add_limit
    ActiveRecord::Base.transaction do
      distributor = User.find_by_mobile(params[:mobile]).distributor
      change_limit = distributor.change_limits.create!(change_limit_params)
      new_limit =  distributor.balance_limit + change_limit.amount
      change_limit.update_attributes!(previous_limit: distributor.balance_limit,
                                      current_limit: new_limit, source: 'admin',
                                      action: 'add', status: 'Done')
      unless current_user.has_role?('super_admin')
       admin_cl =  current_user.admin.change_limits.create!(amount: change_limit.amount,
                                                previous_limit: current_user.admin.balance_limit,
                                                current_limit:  current_user.admin.balance_limit - change_limit.amount,
                                                source: 'self', action: 'less', status: 'Done')
        current_user.admin.update!(balance_limit: admin_cl.current_limit)
      end
      distributor.update!(:balance_limit => new_limit)
      redirect_to admin_distributors_limit_history_path
    end
  rescue Exception => error
    Rails.logger.info error
    redirect_to request.referrer, flash: { error:  "#{error}" }
  end

  def create_less_limit
    ActiveRecord::Base.transaction do  
      distributor = User.find_by_mobile(params[:mobile]).try(:distributor)
      change_limit = distributor.change_limits.create!(change_limit_params)
      new_limit =  distributor.balance_limit - change_limit.amount
      change_limit.update_attributes!(previous_limit: distributor.balance_limit,
                                      current_limit: new_limit, source: 'admin',
                                      action: 'less', status: 'Done')
      unless current_user.has_role?('super_admin')
        current_user.admin.change_limits.create!(amount: change_limit.amount,
                                                previous_limit: current_user.admin.balance_limit,
                                                current_limit:  current_user.admin.balance_limit + change_limit.amount,
                                                source: 'self', action: 'add', status: 'Done')
      end
      distributor.update!(balance_limit: new_limit)
      redirect_to admin_distributors_limit_history_path
    end  
  rescue Exception => error
    Rails.logger.info error
    redirect_to request.referrer, flash: { error:  "#{error}"}
  end

  def view_limit
    load_distributors
  end

  def logs
    @distributor_limit_history = ChangeLimit.where(changable_type: 'Distributor').order(created_at: :desc).page(params[:page]).per(25)
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def download_view_limit
    @distributors = Distributor.all
    filename = "#{Time.now.strftime('%d%m')}-Distributor_limit.xls"
    respond_to do |format|
      format.xls do
        response.headers['Content-Type'] = 'application/excel'
        response.headers['Content-Disposition'] = "attachment; filename=#{filename}"
      end
    end      
  end

  def download_limit_history
    date = 60.days.ago
    @limit_history = ChangeLimit.where("changable_type = 'Distributor' and created_at> '#{date.strftime("%d-%m-%Y").to_date.beginning_of_day}' and status!='Transaction'").order(created_at: :desc)
    filename = "Distributor-limit-history.xls"
    respond_to do |format|
      format.xls do
        response.headers['Content-Type'] = 'application/vnd.ms-excel; charset=utf-8'
        response.headers['Content-Disposition'] = "attachment; filename=#{filename}"
      end
    end      
  end

  def load_distributors
    @distributors = Distributor.page(params[:page]).per(PER_PAGE).order(created_at: :desc)
  end

  def load_limit_history
    @limit_history = ChangeLimit.where(changable_type: 'Distributor').page(params[:page]).per(PER_PAGE).order(created_at: :desc)
  end
  private

  def distributor_params
    params.require(:user).permit!
  end

  def search_params
    params.require(:distributor).permit!
  end

  def change_limit_params
    params.require(:change_limit).permit(:amount, :note)
  end
end
