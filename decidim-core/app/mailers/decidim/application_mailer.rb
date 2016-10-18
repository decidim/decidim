# frozen_string_literal: true
module Decidim
  # Main application mailer configuration. Inherit from this to create new
  # mailers.
  class ApplicationMailer < ActionMailer::Base
    include Roadie::Rails::Automatic

    default from: Decidim.config.mailer_sender
    layout "mailer"
  end
end
