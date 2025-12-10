Rails.application.routes.draw do
  get 'tutorials/install'
  post 'tutorials/skip', to: 'tutorials#skip'
  get "webmanifest"    => "pwa#manifest"
  get "service-worker" => "pwa#service_worker"

  devise_for :users
  root to: "pages#home"

  get "up" => "rails/health#show", as: :rails_health_check

  get "profile", to: "pages#profile"

  get "faq", to: "pages#faq"

  get "partners", to: "pages#partners"

  get "this_ping/:id", to: "pages#this_ping", as: :this_ping

get "/404", to: proc { [404, {}, ["Not Found"]] }
get "/500", to: proc { [500, {}, ["Internal Server Error"]] }
get "/422", to: proc { [422, {}, ["Internal Server Error"]] }

  namespace :api do
    resources :push_subscriptions, only: [:create, :destroy]
    resources :locations, only: [:create]
  end

  resources :pages, only: :new do
    collection do
      get :home
    end
  end

  resources :pings, only: [:new, :create, :index, :show, :update] do
    member do
      post :share
    end

    resources :chats, only: :create do
      resources :messages, only: :create
    end

  end
    resources :levels, only: [:index, :show]
    resources :rewards, only: [:index, :show]
end
