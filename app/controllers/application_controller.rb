class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from AbstractController::ActionNotFound, with: :render_404
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActionController::ParameterMissing, with: :render_404
  rescue_from ActiveRecord::StatementInvalid, with: :render_404
  rescue_from ActionView::MissingTemplate, with: :handle_missing_template

  def after_sign_up_path_for(resource)
    signed_in_root_path(resource)
  end

  def after_sign_in_path_for(resource)
    return session[:user_return_to] if session[:user_return_to]
    if (resource.roles.pluck(:name) && ['admin', 'super_admin']).any?
      authenticated_user_path
    elsif resource.roles.pluck(:name).include?('distributor')
      distributors_senders_path
    else
      senders_path
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:mobile, :email, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.permit(:sign_in) { |u| u.permit(:login, :mobile, :email, :password, :remember_me) }
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:mobile, :email, :password, :password_confirmation, :current_password) }
  end
  
  def is_super_admin?
    unless current_user.has_role?('super_admin')
      if current_user.has_role?('admin')
        redirect_to authenticated_user_path, flash: { error: 'Unauthorized to access the page' }  
      elsif current_user.has_role?('merchant')
        redirect_to '/merchants', flash:{ error: 'Unauthorized to access the page' }
      elsif current_user.has_role?('distributor')
        redirect_to '/distributors/merchants', flash:{ error: 'Unauthorized to access the page' }
      end
    end  
  end

  def is_distributor?
    if !(current_user.has_role?('super_admin') || current_user.has_role?('distributor'))
      redirect_to 'distributors_merchants_path', flash:{ error: 'Unauthorized to access the page' }
    end
  end

  def is_merchant?
    unless current_user.has_role?('super_admin') || current_user.has_role?('merchant')
      redirect_to distributors_merchants_path, flash:{ error: 'Unauthorized to access the page' }
    end
  end

  def set_cache_buster
    response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
  end

  def render_404(exception = nil)
    logger.info "Rendering 404: #{exception.message}" if exception
    respond_to do |format|
      format.html { render "#{Rails.root}/public/404.html", status: 404 }
      format.json { render json: { status: 404, message: 'Page Not Found' } }
    end
  end

  def handle_missing_template(exception = nil)
    logger.info "Missing Template #{exception.message} " if exception
    respond_to do |format|
      format.html { redirect_to request.referrer }
      format.js { "window.location=#{request.referrer}" }
    end
  end  
end
