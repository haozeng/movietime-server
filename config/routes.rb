Rails.application.routes.draw do
  use_doorkeeper
  resources :brands, only: [:index, :show]
end