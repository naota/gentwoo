Rails.application.routes.draw do
  match '/login' => 'sessions#new', :as => 'login'
  match '/logout' => 'sessions#destroy', :as => 'logout'

  resource :session

  match 'oauth_callback' => 'sessions#oauth_callback', :as => 'oauth_callback'
end
