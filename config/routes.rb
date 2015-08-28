Rails.application.routes.draw do
  devise_for :agents, only: :invitations
  devise_for :organisations

  devise_scope :organisation do
    authenticated :organisation do
      root 'organisations#index', as: :authenticated_root
    end
  end

  resources :organisations, only: [:index]
  resources :invitations, only: [:create]
  resource :agent, only: %i(new create)

  root 'devise/sessions#new'
  get 'reveal_referral_token', to: 'organisations#reveal_referral_link'
end
