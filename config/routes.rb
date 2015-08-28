Rails.application.routes.draw do
  use_doorkeeper
  resources :brands, only: [:index, :show]
  resources :purchase_orders, only: [:index, :show, :create]

  resources :registrations, only: [:create, :update] do
    post 'oauth', on: :collection
  end

  resources :payment_profiles, only: [:create, :index, :show, :destroy]

  resources :tickets, only: [:show, :create] do
    post 'mark_used', on: :member
    post 'mark_unused', on: :member
  end
end