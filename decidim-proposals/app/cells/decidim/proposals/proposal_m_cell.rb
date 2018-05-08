# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders a proposal with its M-size card.
    class ProposalMCell < Decidim::Proposals::ProposalCell
      include Cell::ViewModel::Partial
      include Decidim::TooltipHelper

      def show
        render
      end

      def footer
        render
      end

      def header
        render
      end

      def status
        render
      end

      def badge
        render
      end

      private

      def current_user
        context[:current_user]
      end

      def decidim
        Decidim::Core::Engine.routes.url_helpers
      end

      def resource_path
        resource_locator(model).path
      end

      def body
        truncate(model.body, length: 100)
      end

      def badge_classes
        classes = [badge_state_css]
        classes += if options[:full_badge]
                     ["label", "proposal-status"]
                   else
                     ["card__text--status"]
                   end
        classes.join(" ")
      end
    end
  end
end
