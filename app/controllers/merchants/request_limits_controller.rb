class Merchants::RequestLimitsController < ApplicationController
  PER_PAGE = 10
  before_action :authenticate_user!, :is_merchant?
  before_filter :merchant, only: [:new, :create, :build_request_limit, :load_request_limits]

  def index
    load_request_limits
  end

  def new
    @request_limit = @merchant.request_limits.build
  end

  def create
    build_request_limit
    dist_mobile = current_user.merchant.distributor.mobile rescue nil
    if @request_limit.save!
      @request_limit.update(status: 'On Hold', hidden: false, updated: false, distributor_mobile: dist_mobile)
      redirect_to merchants_request_limits_path, flash: { success: 'Limit Request Successfully Sent'}
    else
      render 'new', flash: { success: 'There was some error requesting limit'}
    end
  end

  def search
    @request_limits = current_user.merchant.request_limits.where(status: "#{params[:status]}").page(params[:page]).per(PER_PAGE).order(created_at: :desc)
    if @request_limits.present?
      render 'index'
    else
      render 'index', flash: { error: 'no Data found' }
    end
  end

  def load_request_limits
    @request_limits = current_user.merchant.request_limits.where(status: 'On Hold').page(params[:page]).per(PER_PAGE).order(created_at: :desc)
  end

  def request_limit_params
    params.require(:request_limit).permit(:amount, :bank, :tracking_id, :quick_request)
  end

  def build_request_limit
    @request_limit ||= @merchant.request_limits.build
    @request_limit.attributes = request_limit_params     
  end

  def merchant
    @merchant = current_user.merchant
  end
end
