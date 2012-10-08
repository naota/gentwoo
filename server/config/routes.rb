Gentwoo::Application.routes.draw do
  match 'emerges/ajaxerrorlog/:id' => 'emerges#ajaxerrorlog'
  match 'users/:name' => 'emerges#useremerges'

  resources :emerges do
    resources :comments
  end
  resources :packages, :users

  match 'my' => 'my#index'
  match 'my/key' => 'my#key'
  match 'my/settings' => 'my#settings'
  match 'my/savesettings' => 'my#savesettings'

  match 'my/emerges' => 'emerges#my'
  match 'packages/:category/:name' => 'emerges#package'
  match 'poppackage' => 'emerges#poppackage'

  match 'emerges/:id/remove' => 'emerges#remove'
  match 'emerges/:id/:type' => 'emerges#show'

  match 'comments(.:format)' => 'comments#index'

  root :to => "emerges#home"
end
