Rails.application.routes.draw do
  resources :apartments
  root "apartment#index"
  # get 'refresh', to: 'apartments#refresh', as: :refresh_listings
  get "refresh", to: "apartment#refresh"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
