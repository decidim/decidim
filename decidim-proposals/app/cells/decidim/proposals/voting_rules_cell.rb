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

      # Whether the proposal-creation limit rule is relevant in the current
      # state.
      #
      # The rule is relevant when a limit is configured and either proposals can
      # be created or voting is not open (in which case it is the only rule that
      # can be shown).
      def proposal_limit_rule?
        return false unless proposal_limit_enabled?

        proposal_creation_enabled? || !voting_open?
      end

      # Whether the vote limit rule is relevant in the current state.
      def vote_limit_rule?
        voting_open? && vote_limit_enabled?
      end

      # Whether the threshold per proposal rule is relevant.
      def threshold_per_proposal_rule?
        voting_open? && threshold_per_proposal_enabled?
      end

      # Whether the accumulate votes beyond threshold rule is relevant.
      def can_accumulate_votes_beyond_threshold_rule?
        voting_open? && can_accumulate_votes_beyond_threshold?
      end

      # Whether the minimum votes per user rule is relevant.
      def minimum_votes_per_user_rule?
        voting_open? && minimum_votes_per_user_enabled?
      end

      def component_settings
        current_component.settings
      end

      def current_settings
        current_component.current_settings
      end

      private

      # Whether voting is currently open in this step.
      def voting_open?
        votes_enabled? && !votes_blocked?
      end

      # Whether creating proposals is enabled in the current step.
      def proposal_creation_enabled?
        current_settings.respond_to?(:creation_enabled) && current_settings.creation_enabled
      end
    end
  end
end
