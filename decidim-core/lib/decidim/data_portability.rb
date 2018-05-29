# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This concern contains the logic related to data portability.
  module DataPortability
    extend ActiveSupport::Concern

    included do
      # Returns a collection scoped by user.
      # This is the default, if you want, you can overwrite in each Class to be export.
      def self.user_collection(user)
        where(decidim_author_id: user.id)
      end

      # Returns a Default export serializer
      def self.export_serializer
        Decidim::Exporters::Serializer
      end

      # Returns a collection of images scoped by User.
      # Returns nil for default.
      def self.data_portability_images(_user)
        nil
      end
    end
  end
end
