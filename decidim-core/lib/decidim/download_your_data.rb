# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This concern contains the logic related to download your data.
  module DownloadYourData
    extend ActiveSupport::Concern

    included do
      # Returns a collection scoped by user.
      # This is the default, if you want, you can overwrite in each Class to be export.
      def self.user_collection(user)
        return unless user.is_a?(Decidim::User)

        where(decidim_author_id: user.id, decidim_author_type: "Decidim::UserBaseEntity")
      end

      # Returns a Default export serializer
      def self.export_serializer
        Decidim::Exporters::Serializer
      end

      # Returns a collection of images scoped by User.
      # Returns nil for default.
      def self.download_your_data_images(_user)
        nil
      end
    end
  end
end
