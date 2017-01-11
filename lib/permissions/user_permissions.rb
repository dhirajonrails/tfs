module Permissions
  module UserPermissions
    def flash_notification_check
      check(['admin', 'flash_notification'])
    end

    def message_notification_check
      check(['admin', 'message_notification'])
    end
    def change_user_password_check
      check(['admin', 'change_user_password'])
    end

    def check roles_to_check
      unless current_user.has_role?('super_admin')
        unless (roles_to_check - current_user.roles.pluck(:name)).empty?
          redirect_to request.referrer ? request.referrer : authenticated_user_path, flash: { error:  'You are not allowed to access this page, please ask for permission' }
        end
      end
    end
  end
end
