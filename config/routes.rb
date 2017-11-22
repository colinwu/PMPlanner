PmPlanner::Application.routes.draw do
  resources :news
  get 'admin', to: 'admin#index'

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
  
  resources :parts_for_pms do
    get :autocomplete_part_name, on: :collection
    collection do
      post 'new1'
    end
  end
  
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
      get 'mark_news_read'
      post 'act_as'
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
      get 'autocomplete_client_name'
      get 'do_search'
      post 'handle_checked'
      get 'my_pm_list'
      post 'parts_for_multi_pm'
      delete 'rm_contact'
      get 'search'
      post 'send_order'
      post 'write_parts_order'
      post 'show_or_hide_backup'
    end
    member do
      get 'enter_data'
      get 'analyze_data'
      get 'service_history'
      post 'record_data'
      post 'parts_for_pm'
      post 'add_contact_for'
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
