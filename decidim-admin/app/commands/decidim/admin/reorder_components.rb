# frozen_string_literal: true

module Decidim
  module Admin
    # A command that reorders a collection of components
    class ReorderComponents < Decidim::Command
      # Public: Initializes the command.
      #
      # components - the components to reorder
      # order - an Array holding the order of IDs of the components
      def initialize(components, order)
        @components = components
        @order = order
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the data was not valid and we could not proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless valid_params?

        reorder_components
        broadcast(:ok)
      end

      private

      attr_reader :components, :order

      def valid_params?
        order.present? && components.present?
      end

      def reorder_components
        transaction do
          order.each_with_index do |id, index|
            component = components.find_by(id:)
            component.update!(weight: index + 1) if component.present?
          end
        end
      end
    end
  end
end
