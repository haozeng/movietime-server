Rails.application.routes.draw do
  # devise_for :users
  use_doorkeeper
  resources :brands, only: [:index, :show]
  resources :purchase_orders, only: [:index, :show, :create]
end