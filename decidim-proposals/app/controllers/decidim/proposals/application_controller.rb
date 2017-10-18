# frozen_string_literal: true

module Decidim
  module Proposals
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    #
    # Note that it inherits from `Decidim::Features::BaseController`, which
    # override its layout and provide all kinds of useful methods.
    class ApplicationController < Decidim::Features::BaseController
      helper_method :proposal_limit_reached?

      private

      def proposal_limit_reached?
        return false unless proposal_limit

        current_user_proposals.count >= proposal_limit
      end
    end
  end
end
