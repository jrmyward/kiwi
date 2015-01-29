Kiwi::Application.routes.draw do
  devise_for :users, :controllers => {
    :registrations      => "registrations",
    :omniauth_callbacks => "omniauth_callbacks"
  }

  root :to => 'events#index'
  resources :users

  get '/events/on_date', to: 'events#on_date', as: 'events_on_date'
  get '/events/from_date', to: 'events#from_date', as: 'events_from_date'
  resources :events


  get '/weekly', :to => 'weekly#index', :as => 'weekly'
  get '/about', :to => 'static#about', :as => 'about'
  get '/faq', :to => 'static#faq', :as => 'faq'
  get '/termsofservice', :to => 'static#termsofservice', :as => 'termsofservice'
  get '/privacy', :to => 'static#privacy', :as => 'privacy'

  namespace :api do
    api version: 1, module: 'v1' do
      resources :events, only: [:index, :show, :create, :update, :destroy] do
        resources :upvote, only: [:index, :create]
        delete 'upvote', to: 'upvote#destroy'

        resources :comments, only: [:index, :create, :destroy]
        resources :reminders, only: [:index, :create, :destroy]
      end
      resources :subkasts, only: [:index]
      resources :comments, only: [:destroy] do
        resources :replies, only: [:create]
        post 'upvote', to: 'comment_upvote#create'
        delete 'upvote', to: 'comment_upvote#destroy'

        post 'downvote', to: 'comment_downvote#create'
        delete 'downvote', to: 'comment_downvote#destroy'
      end
      resources :reminder_intervals, only: [:index]
    end
  end

  get '/change_password',        :to => 'passwords#change_password',  :as => 'change_password'
  get '/api/events/eventsByDate', :to => 'backwards#by_date', :as => 'events_by_date'
  get '/api/events/:id/comments', :to => 'backwards#comments', :as => 'events_comments'

  get '/welcome', to: 'home#welcome', as: 'time_zone'
  get '/:subkast_slug', to: 'events#index', as: :events_by_subkast
end
