# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern with the components needed when you want a model to have a
  # reference.
  module HasReference
    extend ActiveSupport::Concern

    included do
      after_commit :store_reference, on: [:create, :update]

      validates :reference, presence: true, on: :update

      def reference
        self[:reference] || calculate_reference
      end

      private

      # Public: Calculates a unique reference for the model using the function
      # provided by configuration. Works for both component resources and
      # participatory spaces.
      #
      # Returns a String.
      def calculate_reference
        Decidim.reference_generator.call(self, respond_to?(:component) ? component : nil)
      end

      # Internal: Sets the unique reference to the model. Note that if the resource
      # implements `Decidim::Traceable` then any normal update (or `update`)
      # will create a new version through an ActiveRecord update callback, but here
      # we can't track the author of the version, so we use the `update_column` method
      # which does not trigger callbacks.
      #
      # Returns nothing.
      def store_reference
        self[:reference] ||= calculate_reference
        return unless changed?

        # rubocop:disable Rails/SkipsModelValidations
        update_column(:reference, self[:reference])
        # rubocop:enable Rails/SkipsModelValidations
      end
    end
  end
end
