require 'sidekiq/web'

Rails.application.routes.draw do
  #mount_devise_token_auth_for 'User', at: 'auth'
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  devise_for :users, controllers: { passwords: 'users/passwords' }
  mount Sidekiq::Web => '/sidekiq' 
  mount ActiveStorage::Engine => '/attachments'
  
  root "products#index"

  resources :products do
    collection do
      get :search
    end
    member do
      get 'download'
    end
    # Reviews có thể được tạo từ product page
    resources :reviews, only: [:new, :create]
  end
  
  resource :cart, only: [:show] do
    post :add_item
    delete :remove_item
  end
  
  resources :orders, only: [:new, :create, :index, :show] do
    member do
      patch :retry_payment
    end
  end

  # Reviews routes - chính
  resources :reviews, except: [:new] do
    # Không cần nested vì reviews có thể được access độc lập
  end

  resources :product_imports, only: [:new, :create]
  
  resources :order_items do  # Sửa orders_items thành order_items
    member do
      post :download
    end
  end

  #API routes
  namespace :api do 
    namespace :v1 do
      devise_for :users,
        path: '',
        path_names: {
          sign_in: 'login',
          sign_out: 'logout',
          registration: 'signup'
        },
        controllers: {
          sessions: 'api/v1/sessions',
          registrations: 'api/v1/registrations'
        },
        defaults: { format: :json } 

      resources :products do
        member do
          get :download
        end
        collection do
          get :search
        end
        # API reviews for products
        resources :reviews, only: [:index, :create]
      end
      
      resources :users do
        member do
          patch :approve
          patch :block  # Sửa duplicate patch :approve
        end
      end
      
      resources :orders, except: [:new, :edit] do
        member do
          post :retry_payment
          post :refund
        end
      end
      
      # API reviews (standalone)
      resources :reviews, except: [:new, :edit]
      
      resource :cart, only: [:show] do
        post :add_item
        delete :remove_item
      end
    end
  end
  
  #Web routes
  resources :users, only: [:index, :show, :edit, :update] do
    member do
      patch :approve
      patch :block
    end
  end
  
  get 'reports/buyer', to: 'reports#buyer'
  get 'reports/seller', to: 'reports#seller'
  get 'reports/admin', to: 'reports#admin'
end