Rails.application.routes.draw do
  scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
    devise_for :agents, only: :invitations
    devise_for :organisations

    devise_scope :organisation do
      root 'organisations#index', as: :organisation_root
    end

    root 'devise/sessions#new'

    resources :organisations, only: [:index]
    resources :invitations, only: [:create]
    resource :agent, only: %i(new create)
    resource :locale, only: [:update]
    get 'reveal_referral_token', to: 'organisations#reveal_referral_link'
  end

  get '', to: redirect("/#{I18n.locale}", status: 302)
end
