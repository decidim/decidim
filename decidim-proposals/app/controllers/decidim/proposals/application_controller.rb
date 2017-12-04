# frozen_string_literal: true

module Decidim
  module Proposals
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    #
    # Note that it inherits from `Decidim::Features::BaseController`, which
    # override its layout and provide all kinds of useful methods.
    class ApplicationController < Decidim::Features::BaseController
      helper Decidim::Messaging::ConversationHelper

      helper_method :proposal_limit_reached?

      private

      def proposal_limit
        return nil if feature_settings.proposal_limit.zero?
        feature_settings.proposal_limit
      end

      def proposal_limit_reached?
        return false unless proposal_limit

        proposals.where(author: current_user).count >= proposal_limit
      end

      def proposals
        Proposal.where(feature: current_feature)
      end
    end
  end
end
