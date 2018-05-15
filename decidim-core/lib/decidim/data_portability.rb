# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This concern contains the logic related to data portability.
  module DataPortability
    extend ActiveSupport::Concern

    included do
      def self.user_collection(user)
        where(decidim_author_id: user.id)
      end

      def self.export_serializer
        Decidim::Exporters::Serializer
      end
    end
  end
end
