# frozen_string_literal: true

module Decidim
  module Admin
    # This command gets called when a feature is unpublished from the admin panel.
    class UnpublishFeature < Rectify::Command
      # Public: Initializes the command.
      #
      # feature - The feature to unpublish.
      # current_user - the user performing the action
      def initialize(feature, current_user)
        @feature = feature
        @current_user = current_user
      end

      # Public: Unpublishes the Feature.
      #
      # Broadcasts :ok if unpublished, :invalid otherwise.
      def call
        unpublish_feature

        broadcast(:ok)
      end

      private

      attr_reader :feature, :current_user

      def unpublish_feature
        Decidim.traceability.perform_action!(
          :unpublish,
          feature,
          current_user
        ) do
          feature.unpublish!
          feature
        end
      end
    end
  end
end
