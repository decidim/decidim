# frozen_string_literal: true
module Decidim
  # Main application mailer configuration. Inherit from this to create new
  # mailers.
  class ApplicationMailer < ActionMailer::Base
    include LocalisedMailer
    include Roadie::Rails::Automatic
    include Roadie::Rails::Mailer

    default from: Decidim.config.mailer_sender
    layout "decidim/mailer"
  end
end
