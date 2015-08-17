Rails.application.routes.draw do
  use_doorkeeper
  resources :brands, only: [:index, :show]
  resources :purchase_orders, only: [:index, :show, :create]
  resources :registrations, only: [:create, :update] do
    post 'oauth', on: :collection
  end
end