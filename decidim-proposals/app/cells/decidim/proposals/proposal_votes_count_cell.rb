# frozen_string_literal: true

module Decidim
  module Proposals
    # Renders the votes count (progress bar or participatory texts variant)
    # for a given proposal
    class ProposalVotesCountCell < Decidim::ViewModel
      include Cell::ViewModel::Partial
      include Decidim::Proposals::ProposalVotesHelper

      alias resource model

      def show
        return unless can_see_votes?

        render
      end

      private

      def can_see_votes?
        return false if component.current_settings.votes_hidden?

        space_member? || admin? || transparent_space?
      end

      def space_member?
        participatory_space.can_participate?(current_user)
      end

      def admin?
        current_user&.admin?
      end

      def transparent_space?
        participatory_space.try(:transparent?)
      end

      def participatory_texts_variant?
        component.settings.participatory_texts_enabled? && from_proposals_list?
      end

      def component
        resource.component
      end
      alias current_component component

      def participatory_space
        component.participatory_space
      end

      def current_settings
        component.current_settings
      end

      def component_settings
        component.settings
      end

      def from_proposals_list?
        options[:from_proposals_list]
      end

      def progress
        resource.proposal_votes_count || 0
      end

      def total
        resource.maximum_votes || 0
      end

      def progress_bar_class
        total.positive? ? "card__proposals-votes-limited" : "card__proposals-votes-unlimited"
      end

      def element_id
        "proposal-#{resource.id}-votes-count"
      end
    end
  end
end
