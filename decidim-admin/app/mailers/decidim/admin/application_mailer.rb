# frozen_string_literal: true

module Decidim
  module Admin
    # Custom application mailer, scoped to the admin mailer.
    #
    class ApplicationMailer < ActionMailer::Base
      default from: Decidim.config.mailer_sender
      layout "mailer"
    end
  end
end
