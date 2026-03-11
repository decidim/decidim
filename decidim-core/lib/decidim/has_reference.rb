# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern with the components needed when you want a model to have a
  # reference.
  module HasReference
    extend ActiveSupport::Concern

    included do
      # Two callbacks are needed here:
      #
      # 1. `before_save`: Sets the reference *before* the first save to satisfy NOT NULL
      #    constraints. At this point the record has no ID yet, so a temporary reference
      #    is generated without the ID. This is necessary for data importers.
      #
      # 2. `after_commit`: After the record is saved and has an ID, recalculates the
      #    reference with the ID included (see `Decidim.reference_generator`) and
      #    persists it via `update_column`. This runs outside the transaction.
      before_save :store_reference
      after_commit :store_reference

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
      # we cannot track the author of the version, so we use the `update_column` method
      # which does not trigger callbacks.
      #
      # Returns nothing.
      def store_reference
        self[:reference] ||= calculate_reference
        return unless persisted? && changed?

        # rubocop:disable Rails/SkipsModelValidations
        update_column(:reference, self[:reference])
        # rubocop:enable Rails/SkipsModelValidations
      end
    end
  end
end
