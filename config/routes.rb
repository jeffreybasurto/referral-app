Rails.application.routes.draw do
  devise_for :agents, only: :invitations
  devise_for :organisations

  devise_scope :organisation do
    authenticated :organisation do
      root 'organisations#index', as: :authenticated_root
    end
  end

  root 'devise/sessions#new'

  resources :organisations, only: [:index]
  resources :invitations, only: [:create]
end
