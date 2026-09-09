Rails.application.routes.draw do
  resources :users, only: [] do
    resources :diaries, only: [ :index ]
  end

  get "/login", to: "sessions#new", as: "login"
  delete "/logout", to: "sessions#destroy", as: "logout"

  get "auth/discord/callback", to: "sessions#create"
  get "auth/failure", to: "sessions#failure"
end
