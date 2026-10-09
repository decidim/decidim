# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command that reorders the phases in a participatory process.
      class ReorderParticipatoryProcessPhases < Decidim::Command
        # Public: Initializes the command.
        #
        # collection - an ActiveRecord::Relation of phases
        # order - an Array holding the order of IDs of phases
        def initialize(collection, order)
          @collection = collection
          @order = order
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the data was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if order.blank?

          reorder_phases
          broadcast(:ok)
        end

        private

        attr_reader :collection

        def reorder_phases
          data = order.each_with_index.inject({}) do |hash, (id, index)|
            hash.update(id => { position: index })
          end

          # rubocop:disable-next Rails/SkipsModelValidations
          ParticipatoryProcessPhase.transaction do
            collection.update_all(position: nil)
            collection.reload
            collection.update(data.keys, data.values)
            collection.each(&:save!)
          end
        end

        def order
          return nil unless @order.is_a?(Array) && @order.present?

          @order
        end
      end
    end
  end
end
