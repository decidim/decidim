# frozen_string_literal: true
module Decidim
  module Admin
    # A command that reorders the steps in a participatory process.
    class ReorderParticipatoryProcessSteps < Rectify::Command
      # Public: Initializes the command.
      #
      # collection - an ActiveRecord::Relation of steps
      # order - an Array holding the order of IDs of steps
      def initialize(collection, order)
        @collection = collection
        @order = order
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the data wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless order.present?

        reorder_steps
        broadcast(:ok)
      end

      private

      attr_reader :collection

      def reorder_steps
        data = order.each_with_index.inject({}) do |hash, (id, index)|
          hash.update(id => { position: index })
        end

        ParticipatoryProcessStep.transaction do
          collection.update_all(position: nil)
          collection.update(data.keys, data.values)
        end
      end

      def order
        return nil unless @order.is_a?(Array) && @order.present?

        @order
      end
    end
  end
end
