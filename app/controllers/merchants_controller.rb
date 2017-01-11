class MerchantsController < ApplicationController
  PER_PAGE = 10
  before_action :authenticate_user!, :is_merchant?

  def index
    load_merchant
  end

  def new
    @user = User.new
    @merchant = @user.build_merchant
    @profile = @merchant.build_profile
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

  def search_limit_history
    query = []
    query << "quick_request = #{params[:request]}" if params[:request].present?
    query << "status = '#{params[:status]}'" if params[:status].present?
    @limit_history = current_user.merchant.change_limits.where(query.join(' AND ')).page(params[:page]).per(PER_PAGE).order(created_at: :desc)              
    if @limit_history.present?
      render 'limit_history'
    else
      render 'limit_history', flash: { error: 'No data found'}
    end
  end

  def download_limit_history
    date = 60.days.ago
    @limit_history = current_user.merchant.change_limits.where("created_at> '#{date.strftime("%d-%m-%Y").to_date.beginning_of_day}'").order(created_at: :desc)
    filename = "limit-history.xls"
    respond_to do |format|
      format.xls do
        response.headers['Content-Type'] = 'application/vnd.ms-excel; charset=utf-8'
        response.headers['Content-Disposition'] = "attachment; filename=#{filename}"
      end
    end      
  end

  def load_limit_history
    @limit_history = current_user.merchant.change_limits.page(params[:page]).per(PER_PAGE).order(created_at: :desc)
  end

  def merchant_params
    params.require(:user).permit!
  end

  def change_limit_params
    params.require(:change_limit).permit(:amount, :note)
  end

end
