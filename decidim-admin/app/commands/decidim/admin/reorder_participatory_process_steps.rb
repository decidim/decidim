# frozen_string_literal: true
module Decidim
  module Admin
    # A command that reorders the steps in a participatory process.
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
        return broadcast(:invalid) unless order

        reorder_steps
        broadcast(:ok)
      end

      private

      attr_reader :order_string, :collection

      def order
        return @order if @order
        return nil unless order_string.present?

        begin
          @order = JSON.parse(order_string)
        rescue JSON::ParserError
          return nil
        end

        return nil unless @order.is_a?(Array) && @order.present?
        @order
      end

      def reorder_steps
        data = order.each_with_index.inject({}) do |hash, (id, index)|
          hash.update(id => { position: index })
        end

        collection.update(data.keys, data.values)
      end
    end
  end
end
