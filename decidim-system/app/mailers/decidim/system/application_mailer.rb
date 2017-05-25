# frozen_string_literal: true

module Decidim
  module System
    # Custom application mailer, scoped to the system mailer.
    #
    class ApplicationMailer < ActionMailer::Base
      default from: Decidim.config.mailer_sender
      layout "mailer"
    end
  end
end
