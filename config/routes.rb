Rails.application.routes.draw do
  get 'product_imports/create'
  get 'reviews/create'
  get 'orders/index'
  get 'orders/show'
  get 'orders/create'
  get 'carts/show'
  get 'carts/add_item'
  get 'carts/remove_item'
  get 'users/index'
  get 'users/show'
  get 'users/edit'
  get 'users/update'
  get 'users/approve'
  get 'users/block'
  get 'products/index'
  get 'products/show'
  get 'products/new'
  get 'products/create'
  get 'products/edit'
  get 'products/update'
  get 'products/destroy'
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
  resources :orders, only: [:index, :show, :create]
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
