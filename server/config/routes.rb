Gentwoo::Application.routes.draw do
  match 'emerges/ajaxerrorlog/:id' => 'emerges#ajaxerrorlog'

  resources :emerges
  match 'my' => 'my#index'
  match 'my/key' => 'my#key'

  match 'my/emerges' => 'emerges#my'
  match 'packages/:category/:name' => 'emerges#package'
  match 'users/:name' => 'emerges#useremerges'

  match 'emerges/:id/:type' => 'emerges#show'

  root :to => "emerges#home"
end
