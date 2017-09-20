# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This concern contains the logic related to publication and promotion.
  module Publicable
    extend ActiveSupport::Concern

    class_methods do
      # Public: Scope to return only published records.
      #
      # Returns an ActiveRecord::Relation.
      def published
        where.not(published_at: nil)
      end

      # Public: Scope to return only unpublished records.
      #
      # Returns an ActiveRecord::Relation.
      def unpublished
        where(published_at: nil)
      end
    end

    # Public: Checks whether the record has been published or not.
    #
    # Returns true if published, false otherwise.
    def published?
      published_at.present?
    end

    #
    # Public: Publishes this feature
    #
    # Returns true if the record was properly saved, false otherwise.
    def publish!
      update_attributes!(published_at: Time.current)
    end

    #
    # Public: Unpublishes this feature
    #
    # Returns true if the record was properly saved, false otherwise.
    def unpublish!
      update_attributes!(published_at: nil)
    end
  end
end
