# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders a proposal with its M-size card.
    class ProposalMCell < Decidim::Proposals::ViewModel
      property :title

      def show
        render
      end

      def footer
        render
      end

      private

      def resource_path
        resource_locator(model).path
      end

      def from_inside?
        true if context[:from].to_s.include?(:inside.to_s)
      end

      def from_outside?
        true if context[:from].to_s.include?(:outside.to_s)
      end

      def body
        truncate(model.body, length: 100)
      end

      def controller
        context[:controller] || controller
      end

      def current_settings
        model.feature.current_settings
      end
      #
      def feature_settings
        controller.feature_settings
      end

      def action_authorization(action)
        controller.action_authorization(action)
      end

      def current_user
        controller.current_user
      end
    end
  end
end
