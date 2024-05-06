# frozen_string_literal: true

module Decidim
  module System
    # Custom application mailer, scoped to the system mailer.
    #
    class ApplicationMailer < ActionMailer::Base
      default from: email_address_with_name(Decidim.config.mailer_sender, Decidim.config.application_name)
      layout "mailer"
    end
  end
end
