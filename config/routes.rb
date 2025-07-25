require 'sidekiq/web'

Rails.application.routes.draw do
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
  end
  resource :cart, only: [:show] do
    post :add_item
    delete :remove_item
  end
  resources :orders, only: [:new, :create, :index, :show] 
  resources :reviews, only: [:create]
  resources :product_imports, only: [:new, :create]
  resources :orders_items do
    member do
      post :download
    end
  end
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