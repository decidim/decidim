# frozen_string_literal: true

Rails.application.configure do
  config.action_mailer.preview_path = Decidim::Initiatives::Engine.root.join("spec/mailers")
end
