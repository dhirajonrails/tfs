module Permissions
  module MerchantPermissions
    def merchant_index_check
      unless current_user.has_role?('super_admin')
        unless (['admin', 'merchant_view'] - current_user.roles.pluck(:name)).empty?
          redirect_to request.referrer ? request.referrer : authenticated_user_path, flash:{ error:  'You are not allowed to access this page, please ask for permission' }
        end
      end
    end

    def merchant_new_check
      unless current_user.has_role?('super_admin')
        unless (['admin', 'merchant_new'] - current_user.roles.pluck(:name)).empty?
          redirect_to request.referrer ? request.referrer : authenticated_user_path, flash:{ error:  'You are not allowed to access this page, please ask for permission' }
        end
      end
    end

    def merchant_edit_check
      unless current_user.has_role?('super_admin')
        unless (['admin', 'merchant_edit'] - current_user.roles.pluck(:name)).empty?
          redirect_to request.referrer ? request.referrer : authenticated_user_path, flash:{ error:  'You are not allowed to access this page, please ask for permission' }
        end
      end
    end

    def merchant_update_check
      unless current_user.has_role?('super_admin')
        unless (['admin', 'merchant_update'] - current_user.roles.pluck(:name)).empty?
          redirect_to request.referrer ? request.referrer : authenticated_user_path, flash:{ error:  'You are not allowed to access this page, please ask for permission' }
        end
      end
    end

    def merchant_add_limit_check
      unless current_user.has_role?('super_admin')
        unless (['admin', 'merchant_add_limit'] - current_user.roles.pluck(:name)).empty?
          redirect_to request.referrer ? request.referrer : authenticated_user_path, flash:{ error:  'You are not allowed to access this page, please ask for permission' }
        end
      end
    end

    def merchant_less_limit_check
      unless current_user.has_role?('super_admin')
        unless (['admin', 'merchant_less_limit'] - current_user.roles.pluck(:name)).empty?
          redirect_to request.referrer ? request.referrer : authenticated_user_path, flash:{ error:  'You are not allowed to access this page, please ask for permission' }
        end
      end
    end

    def merchant_view_limit_check
      unless current_user.has_role?('super_admin')
        unless (['admin', 'merchant_view_limit'] - current_user.roles.pluck(:name)).empty?
          redirect_to request.referrer ? request.referrer : authenticated_user_path, flash:{ error:  'You are not allowed to access this page, please ask for permission' }
        end
      end
    end

    def merchant_limit_history_check
      unless current_user.has_role?('super_admin')
        unless (['admin', 'merchant_limit_history'] - current_user.roles.pluck(:name)).empty?
          redirect_to request.referrer ? request.referrer : authenticated_user_path, flash:{ error:  'You are not allowed to access this page, please ask for permission' }
        end
      end
    end

  end
end
