Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  get "up" => "rails/health#show", as: :rails_health_check

  resources :pings, only: [:create, :index, :show] do
    resources :chats, only: :create do
      resources :messages, only: :create
    end

    resources :levels, only: [:index, :show]
    resources :rewards, only: [:index, :show]
  end


end
