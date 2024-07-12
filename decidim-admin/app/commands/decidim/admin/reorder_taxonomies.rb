# frozen_string_literal: true

module Decidim
  module Admin
    # A command that reorders a collection of taxonomies
    # the ones that might be missing.
    class ReorderTaxonomies < Decidim::Command
      # Public: Initializes the command.
      #
      # organization - the Organization where the content blocks reside
      # order - an Array holding the order of IDs of published content blocks.
      def initialize(organization, order, offset = 0)
        @organization = organization
        @order = order
        @offset = offset
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the data was not valid and we could not proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if order.blank?
        return broadcast(:invalid) if collection.empty?

        reorder_steps
        broadcast(:ok)
      end

      private

      attr_reader :organization, :offset

      def reorder_steps
        transaction do
          reset_weights
          collection.reload
          set_new_weights
        end
      end

      def reset_weights
        # rubocop:disable Rails/SkipsModelValidations
        collection.where.not(weight: nil).where(id: order).update_all(weight: nil)
        # rubocop:enable Rails/SkipsModelValidations
      end

      def set_new_weights
        data = order.each_with_index.inject({}) do |hash, (id, index)|
          hash.update(id => index + 1 + offset)
        end

        data.each do |id, weight|
          item = collection.find_by(id:)
          item.update!(weight:) if item.present?
        end
      end

      def order
        return nil unless @order.is_a?(Array) && @order.present?

        @order
      end

      def collection
        @collection ||= Decidim::Taxonomy.where(organization:, parent_id: first_item.parent_id)
      end

      def first_item
        @first_item ||= Decidim::Taxonomy.where(organization:).find(order.first)
      end
    end
  end
end
