# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders a proposal with its M-size card.
    class ProposalMCell < Decidim::Proposals::ViewModel

      def model_path
        resource_locator(model).path
      end

      def current_settings
        controller.current_settings
      end

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
