PmPlanner::Application.routes.draw do
  resources :sessions, only: [:new, :create, :destroy]
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'
  
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
  resources :parts_for_pms
  resources :pm_codes
  resources :parts
  resources :preferences
  
  resources :teams do
    member do
      get 'manager'
      get 'techs'
    end
  end

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
      get 'get_pm_codes_list'
    end
  end

  resources :models
  resources :model_groups do
    member do
      get 'get_targets'
    end
  end

  root to: 'technicians#root_dispatch'
end
