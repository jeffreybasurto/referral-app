Rails.application.routes.draw do
  devise_for :agents, controllers: { registrations: 'agents/registrations' }
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  filter :locale, :exclude => /^\/admin/

  resources :agents, only: [:index] do
    filter :pagination
  end
  get 'reveal_referral_token', to: 'agents#reveal_referral_link'

  resources :organisations, only: [:new, :create]

  devise_scope :agent do
    root 'agents#index', as: :agent_root
  end

  resources :invitations, only: [:create]

  root 'devise/sessions#new'
end
