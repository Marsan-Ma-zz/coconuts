Coconuts::Application.routes.draw do
  # background jobs
  require 'sidekiq/web'
  mount Sidekiq::Web, at: '/moni'
  
  # devise + omniauth
  devise_for :users, :skip => [:sessions, :registration], :controllers => {
    :omniauth_callbacks => "users/omniauth_callbacks"
  } do
    get "logout" => "devise/sessions#destroy"
  end
  authenticated :user do
    root :to => 'home#index'
  end
  devise_for :users

  # main
  root :to => "home#index"
  match "/search" => "search#index", :as => :search
  resources :users, :only => ["show"]
  resources :posts, :only => ["index", "show"]
  #resources :categories
  #resources :tags
  resources :events
  resources :asks, :only => ["index", "show", "new", "create"]
  resources :features
  resources :insiders, :only => ["index"]
  resources :abouts
  resources :iframes #, :only => ["show"]
  resources :bullets do
    collection do
      post :follow
    end
  end
  #resources :techtrend do
  #  collection do
  #    get :inform
  #  end
  #end

  # subscribe custumed feeds
  resources :feeds, :only => ["edit", "create", "update"]
  ["feeds", "feed", "atom", "rss"].each do |i|
    format = (i == "rss") ? 'rss' : 'atom'
    match "#{i}/:slug" => "feeds#show", :defaults => { :format => format }
    match i => "feeds#show", :defaults => { :format => format }
  end
  match "json/:slug" => "feeds#json"

  # let legacy path redirect to belonging
  #match '/:year/:month/:day/:id' => 'posts#show'
  get '/:year/:month/:day/:id/:pname' => 'posts#show', :constraints => { :year => /\d{4}/ }

  # cpanel
  namespace :cpanel do
    root :to => "home#index"
    resources :site_configs
    resources :users
    resources :posts do
      member do
        get :post2social
      end
    end
    resources :categories
    resources :tags
    resources :photos
    resources :subscribes
    resources :feeds
    resources :notes
    resources :asks
    resources :sidebars
    resources :features
    resources :blogs do
      collection do
        get :launch
      end
    end
  end

end
