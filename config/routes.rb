PmPlanner::Application.routes.draw do
  resources :transfers do
    collection do
      get 'to_me'
      get 'from_me'
      post 'handle_checked'
    end
  end
  resources :logs
  resources :counter_data
  resources :counters
  resources :readings
  resources :model_targets
  devise_for :technicians, controllers: { sessions: "technicians/sessions" }
  resources :parts_for_pms
  resources :pm_codes
  resources :parts
  resources :preferences
  resources :teams

  resources :technicians, except: :show do
    member do
      get 'profile'
      put 'profile'
    end
    collection do
      get 'root_dispatch'
      post 'select_territory'
    end
  end

  resources :locations do
    member do
      get 'show_devices_at'
    end
  end
  
  resources :clients do
    member do
      get 'get_locations'
    end
  end

  resources :contacts

  resources :devices do
    collection do
      delete 'rm_contact'
      get 'search'
      post 'parts_for_multi_pm'
      get 'my_pm_list'
      post 'write_parts_order'
      post 'handle_checked'
      post 'send_order'
      post 'send_transfer'
      get 'autocomplete_client_name'
    end
    member do
      get 'enter_data'
      get 'analyze_data'
      get 'service_history'
      post 'record_data'
      post 'parts_for_pm'
      post 'add_contact_for'
      get 'transfer'
    end
  end

  resources :models
  resources :model_groups

  root to: 'technicians#root_dispatch'
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
