Rails.application.routes.draw do
  resources :apartment_unit_visits
  resources :apartments
  resources :testing
  resources :apartments, only: [:index] do
   get 'visits', on: :member
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
