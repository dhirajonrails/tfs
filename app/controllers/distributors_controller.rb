class DistributorsController < ApplicationController
  PER_PAGE = 10
  before_action :authenticate_user!
  before_filter :is_distributor?

  def limit_history
    load_limit_history
  end

  def load_distributor
    @distributor = Distributor.find(params[:id])
  end

  def show
    load_distributor
  end

  def search_limit_history
    @limit_history = current_user.distributor.change_limits.where(status: params[:status]).page(params[:page]).per(PER_PAGE).order(created_at: :desc)    
    if @limit_history.present?
      render 'limit_history'
    else 
      render 'limit_history', flash: { error: 'No Data Found' }
    end
  end

  private

  def load_limit_history
    @limit_history = current_user.distributor.change_limits.page(params[:page]).per(PER_PAGE).order(created_at: :desc)
  end

  def distributor_params
    params.require(:user).permit!
  end

  def change_limit_params
    params.require(:change_limit).permit(:amount, :note)
  end
end
