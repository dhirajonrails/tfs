module Permissions
  module TransactionPermissions
    def normal_view_request_check
      unless current_user.has_role?('super_admin')
        unless (['admin', 'normal_view_request'] - current_user.roles.pluck(:name)).empty?
          redirect_to request.referrer ? request.referrer : authenticated_user_path, flash:{ error:  'You are not allowed to access this page, please ask for permission' }
        end
      end
    end

    def quick_view_request_check
      unless current_user.has_role?('super_admin')
        unless (['admin', 'quick_view_request'] - current_user.roles.pluck(:name) ).empty?
          redirect_to request.referrer ? request.referrer : authenticated_user_path, flash:{ error:  'You are not allowed to access this page, please ask for permission' }
        end
      end
    end

    def edit_request_check
      unless current_user.has_role?('super_admin')
        if Transaction.find(params[:id]).quick_transfer
          unless (['admin', 'quick_edit_request'] - current_user.roles.pluck(:name) ).empty?
            redirect_to request.referrer ? request.referrer : authenticated_user_path, flash:{ error:  'You are not allowed to access this page, please ask for permission' }
          end
        else
          unless (['admin', 'normal_edit_request'] - current_user.roles.pluck(:name) ).empty?
            redirect_to request.referrer ? request.referrer : authenticated_user_path, flash:{ error:  'You are not allowed to access this page, please ask for permission' }
          end
        end
      end
    end

    def update_request_check
      unless current_user.has_role?('super_admin')
        if Transaction.find(params[:id]).quick_transfer
          unless (['admin', 'quick_update_request'] - current_user.roles.pluck(:name) ).empty?
            redirect_to request.referrer ? request.referrer : authenticated_user_path, flash:{ error:  'You are not allowed to access this page, please ask for permission' }
          end
        else
          unless (['admin', 'normal_update_request'] - current_user.roles.pluck(:name) ).empty?
            redirect_to request.referrer ? request.referrer : authenticated_user_path, flash:{ error:  'You are not allowed to access this page, please ask for permission' }
          end
        end
      end
    end  

    def delete_request_check
      unless current_user.has_role?('super_admin')
        if Transaction.find(params[:id]).quick_transfer
          unless (['admin', 'quick_delete_request'] - current_user.roles.pluck(:name) ).empty?
            redirect_to request.referrer ? request.referrer : authenticated_user_path, flash:{ error:  'You are not allowed to access this page, please ask for permission' }
          end
        else
          unless (['admin', 'normal_delete_request'] - current_user.roles.pluck(:name) ).empty?
            redirect_to request.referrer ? request.referrer : authenticated_user_path, flash:{ error:  'You are not allowed to access this page, please ask for permission' }
          end
        end
      end
    end

    def bank_detail_check
      unless current_user.has_role?('super_admin')
        unless (['admin', 'bank_detail'] - current_user.roles.pluck(:name) ).empty?
          redirect_to request.referrer ? request.referrer : authenticated_user_path, flash:{ error:  'You are not allowed to access this page, please ask for permission' }
        end
      end
    end
  end
end