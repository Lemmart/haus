Rails.application.routes.draw do
  # get 'apartment/new'
  # get 'apartment/edit'
  # get 'apartment/show'
  # get 'apartment/index'
  resources :apartments
  root "apartment#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
