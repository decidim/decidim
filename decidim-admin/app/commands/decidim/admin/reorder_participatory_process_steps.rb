# frozen_string_literal: true
module Decidim
  module Admin
    # A command that sets a step in a participatory process as active (and
    # unsets a previous active step)
    class ReorderParticipatoryProcessSteps < Rectify::Command
      # Public: Initializes the command.
      #
      # collection - an ActiveRecord::Relation of steps
      # order_string - a String representing an Array holding the order of IDs
      #   of steps
      def initialize(collection, order_string)
        @collection = collection
        @order_string = order_string
      end

      # Executes the command. Braodcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the data wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless order_string.present?
        @order = JSON.parse(order_string)
        return broadcast(:invalid) unless order.is_a?(Array) && order.present?

        reorder_steps
        broadcast(:ok)
      end

      private

      attr_reader :order_string, :collection, :order

      def reorder_steps
        data = {}
        order.each_with_index do |id, index|
          data[id] = { position: index }
        end

        collection.update(data.keys, data.values)
      end

      def activate_step
        step.update_attribute(:active, true)
      end
    end
  end
end
