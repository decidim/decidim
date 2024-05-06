# frozen_string_literal: true

module Decidim
  module Admin
    # Custom application mailer, scoped to the admin mailer.
    #
    class ApplicationMailer < ActionMailer::Base
      after_action :set_from

      default from: Decidim.config.mailer_sender
      layout "mailer"

      private

      def set_from
        return if @organization.nil?
        return if mail.from.any?(/ /) # if there is an space, there is already a name in the address

        mail.from = email_address_with_name(mail.from.first, @organization.name)
      end
    end
  end
end
