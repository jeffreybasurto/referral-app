Rails.application.routes.draw do
  devise_for :users

  devise_scope :user do
    authenticated :user do
      root 'users#index', as: :authenticated_root
    end
  end

  root 'devise/sessions#new'

  resources :users, only: [:index]
  resources :invitations, only: [:create]
end
