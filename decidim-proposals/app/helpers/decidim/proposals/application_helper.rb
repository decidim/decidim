# frozen_string_literal: true

module Decidim
  module Proposals
    # Custom helpers, scoped to the proposals engine.
    #
    module ApplicationHelper
      include Decidim::Comments::CommentsHelper
      include PaginateHelper
      include ProposalVotesHelper
      include ProposalEndorsementsHelper
      include Decidim::MapHelper
      include Decidim::Proposals::MapHelper
      include CollaborativeDraftHelper
      include ControlVersionHelper

      delegate :minimum_votes_per_user, to: :component_settings

      # Public: The state of a proposal in a way a human can understand.
      #
      # state - The String state of the proposal.
      #
      # Returns a String.
      def humanize_proposal_state(state)
        I18n.t(state, scope: "decidim.proposals.answers", default: :not_answered)
      end

      # Public: The css class applied based on the proposal state.
      #
      # state - The String state of the proposal.
      #
      # Returns a String.
      def proposal_state_css_class(state)
        case state
        when "accepted"
          "text-success"
        when "rejected"
          "text-alert"
        when "evaluating"
          "text-warning"
        when "withdrawn"
          "text-alert"
        else
          "text-info"
        end
      end

      # Public: The state of a proposal in a way a human can understand.
      #
      # state - The String state of the proposal.
      #
      # Returns a String.
      def humanize_collaborative_draft_state(state)
        I18n.t("decidim.proposals.collaborative_drafts.states.#{state}", default: :open)
      end

      # Public: The css class applied based on the collaborative draft state.
      #
      # state - The String state of the collaborative draft.
      #
      # Returns a String.
      def collaborative_draft_state_badge_css_class(state)
        case state
        when "open"
          "success"
        when "withdrawn"
          "alert"
        when "published"
          "secondary"
        end
      end

      def proposal_limit_enabled?
        proposal_limit.present?
      end

      def minimum_votes_per_user_enabled?
        minimum_votes_per_user.positive?
      end

      def proposal_limit
        return if component_settings.proposal_limit.zero?

        component_settings.proposal_limit
      end

      def votes_given
        @votes_given ||= ProposalVote.where(
          proposal: Proposal.where(component: current_component),
          author: current_user
        ).count
      end

      def current_user_proposals
        Proposal.where(component: current_component, author: current_user)
      end

      def follow_button_for(model, large = nil)
        render partial: "decidim/shared/follow_button.html", locals: { followable: model, large: large }
      end

      def votes_count_for(model, from_proposals_list)
        render partial: "decidim/proposals/proposals/participatory_texts/proposal_votes_count.html", locals: { proposal: model, from_proposals_list: from_proposals_list }
      end

      def vote_button_for(model, from_proposals_list)
        render partial: "decidim/proposals/proposals/participatory_texts/proposal_vote_button.html", locals: { proposal: model, from_proposals_list: from_proposals_list }
      end

      def endorsers_for(proposal)
        proposal.endorsements.for_listing.map { |identity| present(identity.normalized_author) }
      end

      def form_has_address?
        @form.address.present? || @form.has_address
      end

      def authors_for(collaborative_draft)
        collaborative_draft.identities.map { |identity| present(identity) }
      end

      def show_voting_rules?
        return false unless votes_enabled?

        return true if vote_limit_enabled?
        return true if threshold_per_proposal_enabled?
        return true if proposal_limit_enabled?
        return true if can_accumulate_supports_beyond_threshold?
        return true if minimum_votes_per_user_enabled?
      end

      def filter_origin_values
        base = if component_settings.official_proposals_enabled
                 [
                   ["all", t("decidim.proposals.application_helper.filter_origin_values.all")],
                   ["official", t("decidim.proposals.application_helper.filter_origin_values.official")]
                 ]
               else
                 [["all", t("decidim.proposals.application_helper.filter_origin_values.all")]]
               end

        base += [["citizens", t("decidim.proposals.application_helper.filter_origin_values.citizens")]]
        base += [["user_group", t("decidim.proposals.application_helper.filter_origin_values.user_groups")]] if current_organization.user_groups_enabled?
        base + [["meeting", t("decidim.proposals.application_helper.filter_origin_values.meetings")]]
      end

      def filter_state_values
        [
          ["except_rejected", t("decidim.proposals.application_helper.filter_state_values.except_rejected")],
          ["accepted", t("decidim.proposals.application_helper.filter_state_values.accepted")],
          ["evaluating", t("decidim.proposals.application_helper.filter_state_values.evaluating")],
          ["rejected", t("decidim.proposals.application_helper.filter_state_values.rejected")],
          ["all", t("decidim.proposals.application_helper.filter_state_values.all")]
        ]
      end

      def filter_type_values
        [
          ["all", t("decidim.proposals.application_helper.filter_type_values.all")],
          ["proposals", t("decidim.proposals.application_helper.filter_type_values.proposals")],
          ["amendments", t("decidim.proposals.application_helper.filter_type_values.amendments")]
        ]
      end
    end
  end
end
