Rails.application.routes.draw do
  devise_for :users, controllers: { passwords: 'users/passwords' }
  root "products#index"

  resources :products do
    collection do
      get :search
    end
  end
  resource :cart, only: [:show] do
    post :add_item
    delete :remove_item
  end
  resources :orders, only: [:new, :create, :index, :show] 
  resources :reviews, only: [:create]
  resources :product_imports, only: [:new, :create]
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