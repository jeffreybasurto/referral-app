# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.1'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.sass, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w(devise/passwords.css
                                                 devise/sessions.css
                                                 devise/invitations.css
                                                 agents/registrations.css
                                                 organisations.css
                                                 agents.css
                                                 mail_templates.css
)