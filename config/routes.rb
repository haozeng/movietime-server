Rails.application.routes.draw do
  resources :brands, only: [:index, :show]
end