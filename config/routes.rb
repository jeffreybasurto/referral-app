Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  filter :locale

  devise_for :organisations, controllers: { registrations: 'devise/registrations' }
  devise_for :agents, only: :invitations

  resources :organisations, only: [:index] do
    filter :pagination
  end

  get 'reveal_referral_token', to: 'organisations#reveal_referral_link'

  devise_scope :organisation do
    root 'organisations#index', as: :organisation_root
  end

  resources :invitations, only: [:create]
  resource :agents, only: %i(new create) do
    match :create, via: %i(get post) #allow GET create to support locale switching after submit
    get :finished
  end

  root 'devise/sessions#new'
end
