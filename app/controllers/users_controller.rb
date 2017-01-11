class UsersController < ApplicationController
  include Permissions::UserPermissions

  before_filter :authenticate_user!
  before_filter :set_cache_buster
  before_filter :is_super_admin?, only: [:dashboard, :change_permissions, :permission_params, :create_admin, :admin_details, :add_admin_limit]
  before_action :flash_notification_check, only: [:notification, :create_notification, :delete_notification]
  before_action :message_notification_check, only: [:message_sender, :send_message]
  before_action :change_user_password_check, only: [:change_user_password, :update_user_password]

  def change_password
    @user = current_user
  end

  def update_password
    @user = User.find(current_user.id)
    if @user.update_with_password(password_params)
      sign_in @user, bypass: true
      if current_user.has_role?('merchant')
        redirect_to senders_path, flash: { success: 'Password updated successfully' }
      elsif current_user.has_role?('distributor')
        redirect_to distributors_senders_path, flash: { success: 'Password updated successfully' }
      else
        redirect_to admin_senders_path, flash: { success: 'Password updated successfully' }
      end
    else
      redirect_to '/change_password', flash: { error: @user.errors }
    end
  end

  def update_user_password
    user = User.find_by_mobile(params[:mobile])
    user.update!(password: params[:user][:password])
    redirect_to request.referrer, flash: { success: 'Password successfully Set'}
  rescue Exception => error
    redirect_to request.referrer, flash: { error: "#{error}"}
  end

  def search
    user = User.find_by_mobile(params[:mobile_number])
    if user.distributor.present?
      name = "#{user.distributor.profile.first_name} #{user.distributor.profile.last_name}"
    elsif user.merchant.present?
      name = "#{user.merchant.profile.first_name} #{user.merchant.profile.last_name}"
    end
    if user.distributor.present? || user.merchant.present?
      render json: { name: name, status: 200 } 
    else
      render json: { status: 404 }
    end
  end

  def dashboard
    @distributor_limit_history = ChangeLimit.where(changable_type: 'Distributor').order(created_at: :desc).page(params[:page]).per(25)
    @merchant_limit_history = ChangeLimit.where(changable_type: 'Merchant').order(created_at: :desc).page(params[:page]).per(25)
    @distributors = Distributor.order(created_at: :desc).page(params[:page]).per(10)
    @merchants = Merchant.order(created_at: :desc).page(params[:page]).per(10)
  end

  def change_permissions
    ActiveRecord::Base.transaction do
      admin_role = Role.find_by_name('admin').id
      admin = User.find(params[:permissions][:admin_id])
      selected = params[:permissions][:selected_permissions].push(admin_role)
      admin.role_ids = selected
      render json: { status: :success }
    end
  end

  def send_message
    User.pluck(:mobile).uniq.each do |mobile|
      RestClient.get "http://login.smsgatewayhub.com/api/mt/SendSMS?APIKey=867ea61b-4a1d-4187-ae4f-610771e0c05e&senderid=TFASMT&channel=2&DCS=0&flashsms=0&number=#{mobile}&text=#{params[:message]}&route=11" rescue nil
    end
    redirect_to admin_message_sender_path, flash: { success: 'Message sent successfully' }
  end

  def admin_details
    admin = User.find(params[:id])
    render json: { admin: admin.as_json(include: [:roles, admin: {include: [:profile]}]), status: :success }
  end

  def create_notification
    Flash.destroy_all
    flash = Flash.create(message: params[:message], status: true)
    render 'notification'
  end

  def delete_notification
    flash = Flash.destroy_all
    render 'notification'
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation, :current_password)
  end

  def create_admin
    user = User.new(admin_user_params)
    user.password = "#{params[:user][:mobile].first(4)}@#{Time.now.getlocal.strftime("%d%m")}"
    user.admin.balance_limit = 0
    user.balance_limit = 0
    user.save!
    user.add_role('admin')
    user.admin.update(mobile: user.mobile)
    render json: { user: user.as_json(include: [admin: {include: [:profile]}]), status: :success }
  end

  def admin_user_params
    params.require(:user).permit!
  end

  def add_admin_limit
    ActiveRecord::Base.transaction do
      admin = User.find(params[:id]).admin
      admin.update!(balance_limit: (admin.balance_limit + params[:limit].to_i))
      render json: { status: :success, amount: params[:limit], admin: admin.user.as_json(include: [admin: {include: [:profile]}]) }
    end
  end
end
