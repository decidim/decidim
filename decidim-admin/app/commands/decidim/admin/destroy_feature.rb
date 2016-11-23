# frozen_string_literal: true
module Decidim
  module Admin
    # This command deals with destroying a Feature from the admin panel.
    class DestroyFeature < Rectify::Command
      # Public: Initializes the command.
      #
      # component - The Feature to be destroyed.
      def initialize(feature)
        @feature = feature
      end

      # Public: Executes the command.
      #
      # Broadcasts :ok if it got destroyed.
      def call
        destroy_feature
        broadcast(:ok)
      end

      private

      def destroy_feature
        transaction do
          @feature.components.each do |component|
            DestroyComponent.call(component)
          end

          @feature.destroy
        end
      end
    end
  end
end
