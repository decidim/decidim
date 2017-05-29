# frozen_string_literal: true

module Decidim
  module Admin
    # This command deals with destroying a Feature from the admin panel.
    class DestroyFeature < Rectify::Command
      # Public: Initializes the command.
      #
      # feature - The Feature to be destroyed.
      def initialize(feature)
        @feature = feature
      end

      # Public: Executes the command.
      #
      # Broadcasts :ok if it got destroyed, raises an exception otherwise.
      def call
        begin
          destroy_feature
        rescue StandardError
          return broadcast(:invalid)
        end
        broadcast(:ok)
      end

      private

      def destroy_feature
        transaction do
          run_before_hooks
          @feature.destroy!
          run_hooks
        end
      end

      def run_before_hooks
        @feature.manifest.run_hooks(:before_destroy, @feature)
      end

      def run_hooks
        @feature.manifest.run_hooks(:destroy, @feature)
      end
    end
  end
end
