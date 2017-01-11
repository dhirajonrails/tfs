Rails.application.routes.draw do
  get 'change_password' => 'users#change_password'
  post 'update_password' => 'users#update_password'
  get 'change_user_password' => 'users#change_user_password'
  post 'update_user_password' => 'users#update_user_password'
  post 'change_permissions' => 'users#change_permissions'
  post 'create_admin' => 'users#create_admin'
  post 'add_admin_limit' => 'users#add_admin_limit'

  # mount ActionCable.server => '/cable'
  # root to: 'homes#index'

  devise_for :users
  unauthenticated :user do
    devise_scope :user do
      root 'homes#index', as: :unauthenticated_root
    end
  end
  
  authenticated :user do
    root 'users#index', as: :authenticated_user
  end

  get 'services' => 'homes#services'
  get 'gallery' => 'homes#gallery'
  get 'mail' => 'homes#mail'
  get 'child_growth' => 'homes#child_growth'
  get 'non_profit_dreams' => 'homes#non_profit_dreams'
  get 'worryless_transfers' => 'homes#worryless_transfers'
  get 'loss_protection' => 'homes#loss_protection'

  # admin/distributors tabs routes
  get 'users/search' => 'users#search'
  get 'admin/dashboard' => 'users#dashboard'
  get 'admin/notification' => 'users#notification'
  get 'admin_details' => 'users#admin_details'
  get 'admin/senders/bank_detail' => 'admin/senders#bank_detail'
  post 'admin/senders/bank_detail' => 'admin/senders#update_bank_detail'
  get 'admin/notification' => 'users#notification'
  get 'admin/message_sender' => 'users#message_sender'
  post 'admin/message_sender' => 'users#send_message'
  post 'admin/notification' => 'users#create_notification'
  delete 'admin/notification' => 'users#delete_notification'
  get 'admin/distributors/add_limit' => "admin/distributors#add_limit"
  get 'admin/distributors/less_limit' => "admin/distributors#less_limit"
  get 'admin/distributors/search' => "admin/distributors#search"
  post 'admin/distributors/create_add_limit' => 'admin/distributors#create_add_limit'
  post 'admin/distributors/create_less_limit' => 'admin/distributors#create_less_limit'
  get 'admin/distributors/view_limit' => "admin/distributors#view_limit"
  get 'admin/distributors/download_view_limit' => "admin/distributors#download_view_limit"
  get 'admin/distributors/download_limit_history' => "admin/distributors#download_limit_history"
  get 'admin/distributors/limit_history' => "admin/distributors#limit_history"
  get 'admin/distributors/search_distributor' => "admin/distributors#search_distributor"
  get 'admin/distributors/search_limit' => "admin/distributors#search_limit"
  get 'admin/request_limits/distributor/search' => "admin/request_limits/distributors#search"
  get 'admin/distributors/search_limit_history' => "admin/distributors#search_limit_history"
  get 'admin/distributors/logs' => "admin/distributors#logs"

  # admin/merchants tabs routes
  get 'admin/merchants/add_limit' => "admin/merchants#add_limit"
  get 'admin/merchants/less_limit' => "admin/merchants#less_limit"
  get 'admin/merchants/search' => "admin/merchants#search"
  get 'admin/merchants/view_limit' => "admin/merchants#view_limit"
  get 'admin/merchants/download_view_limit' => "admin/merchants#download_view_limit"
  get 'admin/merchants/download_limit_history' => "admin/merchants#download_limit_history"
  post 'admin/merchants/create_add_limit' => 'admin/merchants#create_add_limit'
  post 'admin/merchants/create_less_limit' => 'admin/merchants#create_less_limit'
  get 'admin/merchants/limit_history' => "admin/merchants#limit_history"
  get 'admin/merchants/search_merchant' => "admin/merchants#search_merchant"
  get 'admin/merchants/search_limit' => "admin/merchants#search_limit"
  get 'admin/request_limits/merchant/search' => "admin/request_limits/merchants#search"
  get 'admin/merchants/search_limit_history' => "admin/merchants#search_limit_history"
  get 'admin/merchants/logs' => "admin/merchants#logs"

  # didstributor/merchants routes
  get 'distributors/merchants/add_limit' => "distributors/merchants#add_limit"
  get 'distributors/merchants/less_limit' => "distributors/merchants#less_limit"
  get 'distributors/merchants/search' => "distributors/merchants#search"
  get 'distributors/merchants/view_limit' => "distributors/merchants#view_limit"
  post 'distributors/merchants/create_add_limit' => 'distributors/merchants#create_add_limit'
  post 'distributors/merchants/create_less_limit' => 'distributors/merchants#create_less_limit'
  get 'distributors/merchants/limit_history' => "distributors/merchants#limit_history"
  get 'distributors/merchants/search_limit_history' => "distributors/merchants#search_limit_history"
  get 'distributors/merchants/search_merchant' => "distributors/merchants#search_merchant"
  get 'distributors/search_limit_history' => "distributors/search_limit_history"
  get 'admin/senders/download_normal_csv' => "admin/senders#download_normal_csv"

  namespace :admin do
    resources :senders do
      collection do
        get 'search'
        get 'quick_request'
        get 'request_notification'
        post 'bulk_status_update'
        get 'download_rbl_neft_csv'
        get 'download_axis_neft_csv'
        get 'download_quick_csv'
        get 'download_imps_self_report'
      end
    end
    resources :distributors
    resources :merchants
    namespace :request_limits do
      resources :distributors do
        collection do
          get 'request_notification'
        end
      end

      resources :merchants do
        collection do
          get 'request_notification'
        end
      end

    end
  end

  namespace :distributors do
    resources :merchants
    resources :request_limits do
      collection do
        get :merchant_requests
        get 'request_notification'
        get :search_merchant_requests
        get :search
      end
    end
    resources :senders do
      collection do
        get 'search'
        get 'request_notification'
      end
    end
  end

  namespace :merchants do
    resources :request_limits do
      collection do
        get 'search'
      end
    end
  end

  resources :merchants do
    collection do
      get :limit_history
      get :search_limit_history
      get :download_limit_history
    end
  end

  resources :distributors do
    collection do
      get :limit_history
    end
  end

  resources :senders do
    collection do
      get 'charge'
      get 'search_by_mobile'
      get 'validate_number'
      get 'validate_account'
      get 'search_by_account_number'
      get 'beneficiaries'
      get 'search_bank_detail'
      get 'search'
      get 'existing_senders'
      get 'search_sender_detail'
      get 'delete_beneficiary'
      get 'download_service_request'
      get 'rejected_request'
    end
    member do
      get 'download_invoice'
    end
  end




  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
