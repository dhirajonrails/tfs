module Permissions
  module DistributorPermissions
    def distributor_index_check
      unless current_user.has_role?('super_admin')
        unless (['admin', 'distributor_view'] - current_user.roles.pluck(:name)).empty?
          redirect_to request.referrer ? request.referrer : authenticated_user_path, flash:{ error:  'You are not allowed to access this page, please ask for permission' }
        end
      end
    end

    def distributor_new_check
      unless current_user.has_role?('super_admin')
        unless (['admin', 'distributor_new'] - current_user.roles.pluck(:name)).empty?
          redirect_to request.referrer ? request.referrer : authenticated_user_path, flash:{ error:  'You are not allowed to access this page, please ask for permission' }
        end
      end
    end

    def distributor_edit_check
      unless current_user.has_role?('super_admin')
        unless (['admin', 'distributor_edit'] - current_user.roles.pluck(:name)).empty?
          redirect_to request.referrer ? request.referrer : authenticated_user_path, flash:{ error:  'You are not allowed to access this page, please ask for permission' }
        end
      end
    end

    def distributor_update_check
      unless current_user.has_role?('super_admin')
        unless (['admin', 'distributor_update'] - current_user.roles.pluck(:name)).empty?
          redirect_to request.referrer ? request.referrer : authenticated_user_path, flash:{ error:  'You are not allowed to access this page, please ask for permission' }
        end
      end
    end

    def distributor_add_limit_check
      unless current_user.has_role?('super_admin')
        unless (['admin', 'distributor_add_limit'] - current_user.roles.pluck(:name)).empty?
          redirect_to request.referrer ? request.referrer : authenticated_user_path, flash:{ error:  'You are not allowed to access this page, please ask for permission' }
        end
      end
    end

    def distributor_less_limit_check
      unless current_user.has_role?('super_admin')
        unless (['admin', 'distributor_less_limit'] - current_user.roles.pluck(:name)).empty?
          redirect_to request.referrer ? request.referrer : authenticated_user_path, flash:{ error:  'You are not allowed to access this page, please ask for permission' }
        end
      end
    end

    def distributor_view_limit_check
      unless current_user.has_role?('super_admin')
        unless (['admin', 'distributor_view_limit'] - current_user.roles.pluck(:name)).empty?
          redirect_to request.referrer ? request.referrer : authenticated_user_path, flash:{ error:  'You are not allowed to access this page, please ask for permission' }
        end
      end
    end

    def distributor_limit_history_check
      unless current_user.has_role?('super_admin')
        unless (['admin', 'distributor_limit_history'] - current_user.roles.pluck(:name)).empty?
          redirect_to request.referrer ? request.referrer : authenticated_user_path, flash:{ error:  'You are not allowed to access this page, please ask for permission' }
        end
      end
    end

  end
end
