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
    # Public: Publishes this component
    #
    # Returns true if the record was properly saved, false otherwise.
    def publish!
      update!(published_at: Time.current)
    end

    #
    # Public: Unpublishes this component
    #
    # Returns true if the record was properly saved, false otherwise.
    def unpublish!
      update!(published_at: nil)
    end
  end
end
