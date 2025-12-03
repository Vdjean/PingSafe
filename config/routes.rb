Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  get "up" => "rails/health#show", as: :rails_health_check

  get "profile", to: "pages#profile"

  resources :pages, only: :new do
    collection do
      get :home
    end
  end

  resources :pings, only: [:new, :create, :index, :show, :update] do
    resources :chats, only: :create do
      resources :messages, only: :create
    end

    resources :levels, only: [:index, :show]
    resources :rewards, only: [:index, :show]
  end
end
