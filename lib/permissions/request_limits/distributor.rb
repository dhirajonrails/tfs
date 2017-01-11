module Permissions
  module RequestLimits
    module Distributor
      def distributor_limit_request_view_check
        check(['admin', 'distributor_limit_request_view'])
      end

      def distributor_limit_request_edit_check
        check(['admin', 'distributor_limit_request_edit'])
      end

      def distributor_limit_request_update_check
        check(['admin', 'distributor_limit_request_update'])
      end

      def distributor_limit_request_delete_check
        check(['admin', 'distributor_limit_request_delete'])
      end

      def check roles_to_check
        unless current_user.has_role?('super_admin')
          unless (roles_to_check - current_user.roles.pluck(:name)).empty?
            redirect_to request.referrer ? request.referrer : authenticated_user_path, flash:{ error:  'You are not allowed to access this page, please ask for permission' }
          end
        end        
      end
    end
  end
end
