# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A module to be included in the mailers that allows
  # to define the assets host based on an organization host
  module MultitenantAssetHost
    extend ActiveSupport::Concern

    included do
      before_action :set_asset_host

      # set_asset_host allows to redefine the host asset if not specified in application configuration
      # We use a lambda because this code is executed when the application is started
      # and does not allow us to modify it afterwards.
      # Leave action_mailer asset_host empty to use it.
      def set_asset_host
        return if Rails.application.config.action_mailer.asset_host.present?

        self.asset_host = ->(_mail) { "#{protocol}://#{@organization.host}" }
      end

      private

      def protocol
        return "https" if Decidim.force_ssl

        "http"
      end
    end
  end
end
