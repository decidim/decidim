# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A module to be included in mailers that changes the default behaviour so
  # the emails are rendered in the user's locale instead of the default one.
  module MultitenantAssetHost
    extend ActiveSupport::Concern

    included do
      before_action :set_asset_host

      # set_asset_host allows to redefine the host asset if not specified in application configuration
      def set_asset_host
        return if Rails.application.config.action_mailer.asset_host.present?

        self.asset_host = ->(_mail) { "#{use_https? ? "https" : "http"}://#{@organization.host}" }
      end

      private

      def use_https?
        Rails.env.production? || Rails.configuration.force_ssl
      end
    end
  end
end
