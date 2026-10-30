# frozen_string_literal: true

module Decidim
  module Proposals
    # Renders the voting rules callout for a given component (the cell model).
    #
    # The callout is only rendered when at least one rule is relevant for the
    # current component state. This cell centralizes both the visibility logic
    # and the rendering of the rules list, so callers only need to render the
    # cell (or check `show?` when they need the boolean).
    #
    # Example:
    #
    #   <%= cell("decidim/proposals/voting_rules", current_component) %>
    #
    #   <% if cell("decidim/proposals/voting_rules", current_component).show? %>
    #     ...
    #   <% end %>
    class VotingRulesCell < Decidim::ViewModel
      include Cell::ViewModel::Partial
      include Decidim::Proposals::ApplicationHelper

      alias current_component model

      def show
        return unless show?

        render
      end

      # Renders the voting rules as a collapsible flash, used on the proposal
      # show page.
      def proposal_rules
        return unless show?

        call(:proposal)
      end

      # Cell action used by `proposal_rules`.
      def proposal
        render :proposal
      end

      # Whether the voting rules callout should be displayed for the current
      # component state.
      def show?
        proposal_limit_rule? ||
          vote_limit_rule? ||
          threshold_per_proposal_rule? ||
          can_accumulate_votes_beyond_threshold_rule? ||
          minimum_votes_per_user_rule?
      end

      def component_settings
        current_component.settings
      end

      def current_settings
        current_component.current_settings
      end

      private

      def i18n_scope
        "decidim.proposals.proposals.voting_rules"
      end
    end
  end
end
