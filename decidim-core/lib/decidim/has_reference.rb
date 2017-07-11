# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern with the features needed when you want a model to have a
  # reference.
  module HasReference
    extend ActiveSupport::Concern

    included do
      after_commit :store_reference

      validates :reference, presence: true, on: :update

      def reference
        self[:reference] || calculate_reference
      end

      private

      # Public: Calculates a unique reference for the model using the function
      # provided by configuration
      #
      # Returns a String.
      def calculate_reference
        return unless feature
        Decidim.resource_reference_generator.call(self, feature)
      end

      # Internal: Sets the unique reference to the model.
      #
      # Returns nothing.
      def store_reference
        self[:reference] ||= calculate_reference
        save if changed?
      end
    end
  end
end
