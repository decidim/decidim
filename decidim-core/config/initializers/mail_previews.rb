# frozen_string_literal: true

Rails.application.configure do
  config.action_mailer.preview_path = Decidim::Core::Engine.root.join("spec/mailers")
end
