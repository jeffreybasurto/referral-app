Rails.application.routes.draw do
  devise_for :agent, controllers: { registrations: 'agents/registrations', invitations: 'agents/invitations' }
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  filter :locale, :exclude => /^\/admin/

  devise_for :organisations, controllers: { registrations: 'devise/registrations' }

  resources :organisations, only: [:index] do
    filter :pagination
  end

  get 'reveal_referral_token', to: 'organisations#reveal_referral_link'

  devise_scope :organisation do
    root 'organisations#index', as: :organisation_root
  end

  resources :invitations, only: [:create]

  root 'devise/sessions#new'
end
