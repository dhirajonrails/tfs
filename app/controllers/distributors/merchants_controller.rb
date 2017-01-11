class Distributors::MerchantsController < ApplicationController
  PER_PAGE = 10
  before_action :authenticate_user!, :is_distributor?

  def index
    load_merchants
  end

  def new
    @user = User.new
    @merchant = @user.build_merchant
    @profile = @merchant.build_profile
  end

  def create
    user = User.new(merchant_params)
    if user.save_with_merchant
      user.merchant.update_attributes(mobile: user.mobile, source: 'distributor', distributor_id: current_user.distributor.id, balance_limit: 100000, quick_limit: 0)
      user.merchant.change_limits.create!(distributor_mobile: current_user.mobile, amount: 100000, previous_limit: 0, current_limit: 100000, source: 'distributor',                                        
                          action: 'add', note: 'Created Merchant', quick_request: false, status: 'Done')
      redirect_to distributors_merchant_path(id: user.merchant.id), flash:{ success: 'Merchant Successfully Created' }
    else 
      redirect_to new_distributors_merchant_path, flash:{ error: user.errors }
    end 
  end

  def edit
    @user = Merchant.find(params[:id]).user
  end

  def update
    @user = User.find(params[:id])
    @user.attributes = merchant_params
    if @user.save(validate:false)
      redirect_to distributors_merchants_path
    else
      render 'edit', flash:{ error: @user.errors }
    end
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

  def search_merchant
    users = User.joins(merchant: [:profile]).where("users.mobile LIKE ? or profiles.first_name LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    user_ids = []
    users.map do |user|
      user_ids << user.id
    end
    dist_id = current_user.distributor.id
    @merchants = Merchant.where('user_id IN (?) and distributor_id = ?', user_ids, dist_id).page(params[:page]).per(PER_PAGE).order(created_at: :desc)
    if @merchants.present?
      render 'index'
    else
      render 'index', flash: { error: 'No data found'}
    end
  end

  def search
    @merchant = User.find_by_mobile(params[:mobile_number]).try(:merchant)
    if @merchant.present? && @merchant.distributor.id == current_user.distributor.id
      render json: { merchant: @merchant, profile: @merchant.profile, status: 200 } 
    else
      render json: { status: 404 }
    end
  end

  def search_limit_history
    query = []
    query << "quick_request = #{params[:request]}" if params[:request].present?
    query << "status = '#{params[:status]}'" if params[:status].present?
    users = User.joins(merchant: [:profile]).where("users.mobile LIKE ? or profiles.first_name LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    user_ids = []
    users.map do |user|
      user_ids << user.id
    end
    merchants = Merchant.where('user_id IN (?)', user_ids)
    mer_ids = []
    merchants.each do |merchant|
      mer_ids << merchant.id
    end
    query << "changable_id IN (#{mer_ids.join(',')}) and changable_type='Merchant'"
    query << "distributor_mobile = #{current_user.mobile}"
    @limit_history = ChangeLimit.where(query.join(' AND ')).page(params[:page]).per(PER_PAGE).order(created_at: :desc)
    if @limit_history.present?
      render 'limit_history'
    else
      render 'limit_history', flash: { error: 'No data found'}
    end
  end

  def create_add_limit
    @distributor = current_user.distributor
    ActiveRecord::Base.transaction do
      merchant = User.find_by_mobile(params[:mobile]).try(:merchant)
      change_limit = merchant.change_limits.create!(change_limit_params)
      if change_limit.quick_request
        new_limit =  merchant.quick_limit + change_limit.amount
        change_limit.update_attributes!(previous_limit: merchant.quick_limit,
                                        current_limit: new_limit, source: 'distributor',
                                        action: 'add', status: 'Done', quick_request: true,
                                        distributor_mobile: @distributor.mobile)
        merchant.update!(:quick_limit => new_limit)
      else
        new_limit =  merchant.balance_limit + change_limit.amount
        change_limit.update_attributes!(previous_limit: merchant.balance_limit,
                                        current_limit: new_limit, source: 'distributor',
                                        action: 'add', status: 'Done', quick_request: false,
                                        distributor_mobile: @distributor.mobile)
        merchant.update!(:balance_limit => new_limit)
      end
      new_distributor_limit = @distributor.balance_limit - change_limit.amount
      change_distributor_limit = @distributor.change_limits.create!(amount: change_limit.amount,
                                                     note: change_limit.note,
                                                     previous_limit: @distributor.balance_limit,
                                                     current_limit: new_distributor_limit, source: 'distributor',
                                                     action: 'less', status: 'Done')
      @distributor.update!(:balance_limit => new_distributor_limit)
      redirect_to distributors_merchants_limit_history_path
    end
  rescue Exception => error
    render 'add_limit', flash: { error: "There was an error adding limit, check the fields" }
  end

  def create_less_limit
    ActiveRecord::Base.transaction do
      merchant = User.find_by_mobile(params[:mobile]).try(:merchant)
      change_limit = merchant.change_limits.create!(change_limit_params)
      new_limit =  merchant.balance_limit - change_limit.amount
      change_limit.update_attributes!(previous_limit: merchant.balance_limit,
                                      current_limit: new_limit, source: 'distributor',
                                      action: 'less', status: 'Done',
                                      distributor_mobile: current_user.mobile)
      merchant.update(:balance_limit => new_limit)        
      redirect_to distributors_merchants_limit_history_path
    end
  rescue Exception => error
    render 'less_limit', flash:{ error: "There was an error adding limit, check the fields" }
  end

  def view_limit
    load_merchants
  end

  def load_merchants
    @merchants = current_user.distributor.merchants.page(params[:page]).per(PER_PAGE).order(created_at: :desc)
  end

  def load_limit_history
    @limit_history = ChangeLimit.where('distributor_mobile IN (?) ', current_user.mobile).page(params[:page]).per(PER_PAGE).order(created_at: :desc)
  end

  def merchant_params
    params.require(:user).permit!
  end

  def change_limit_params
    params.require(:change_limit).permit(:amount, :note, :quick_request)
  end
end
