# frozen_string_literal: true

module Decidim
  module Proposals
    # Custom helpers, scoped to the proposals engine.
    #
    module ApplicationHelper
      include Decidim::Comments::CommentsHelper
      include PaginateHelper
      include ProposalVotesHelper
      include ::Decidim::EndorsableHelper
      include ::Decidim::FollowableHelper
      include Decidim::MapHelper
      include Decidim::Proposals::MapHelper
      include CollaborativeDraftHelper
      include ControlVersionHelper
      include Decidim::RichTextEditorHelper
      include Decidim::CheckBoxesTreeHelper

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
      # proposal - The proposal to evaluate.
      #
      # Returns a String.
      def proposal_state_css_class(proposal)
        state = proposal.state
        state = proposal.internal_state if proposal.answered? && !proposal.published_state?

        case state
        when "accepted"
          "text-success"
        when "rejected", "withdrawn"
          "text-alert"
        when "evaluating"
          "text-warning"
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

      def not_from_collaborative_draft(proposal)
        proposal.linked_resources(:proposals, "created_from_collaborative_draft").empty?
      end

      def not_from_participatory_text(proposal)
        proposal.participatory_text_level.nil?
      end

      # If the proposal is official or the rich text editor is enabled on the
      # frontend, the proposal body is considered as safe content; that's unless
      # the proposal comes from a collaborative_draft or a participatory_text.
      def safe_content?
        (rich_text_editor_in_public_views? && not_from_collaborative_draft(@proposal)) ||
          ((@proposal.official? || @proposal.official_meeting?) && not_from_participatory_text(@proposal))
      end

      # If the content is safe, HTML tags are sanitized, otherwise, they are stripped.
      def render_proposal_body(proposal)
        Decidim::ContentProcessor.render(render_sanitized_content(proposal, :body), "div")
      end

      # Returns :text_area or :editor based on the organization' settings.
      def text_editor_for_proposal_body(form)
        options = {
          class: "js-hashtags",
          hashtaggable: true,
          value: form_presenter.body(extras: false).strip
        }

        text_editor_for(form, :body, options)
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

      def votes_count_for(model, from_proposals_list)
        render partial: "decidim/proposals/proposals/participatory_texts/proposal_votes_count.html", locals: { proposal: model, from_proposals_list: }
      end

      def vote_button_for(model, from_proposals_list)
        render partial: "decidim/proposals/proposals/participatory_texts/proposal_vote_button.html", locals: { proposal: model, from_proposals_list: }
      end

      def form_has_address?
        @form.address.present? || @form.has_address
      end

      def show_voting_rules?
        return false unless votes_enabled?

        return true if vote_limit_enabled?
        return true if threshold_per_proposal_enabled?
        return true if proposal_limit_enabled?
        return true if can_accumulate_supports_beyond_threshold?
        return true if minimum_votes_per_user_enabled?
      end

      def filter_type_values
        [
          ["all", t("decidim.proposals.application_helper.filter_type_values.all")],
          ["proposals", t("decidim.proposals.application_helper.filter_type_values.proposals")],
          ["amendments", t("decidim.proposals.application_helper.filter_type_values.amendments")]
        ]
      end

      # Options to filter Proposals by activity.
      def activity_filter_values
        base = [
          ["all", t(".all")],
          ["my_proposals", t(".my_proposals")]
        ]
        base += [["voted", t(".voted")]] if current_settings.votes_enabled?
        base
      end

      def filter_origin_values
        origin_values = []
        origin_values << TreePoint.new("official", t("decidim.proposals.application_helper.filter_origin_values.official")) if component_settings.official_proposals_enabled
        origin_values << TreePoint.new("participants", t("decidim.proposals.application_helper.filter_origin_values.participants"))
        origin_values << TreePoint.new("user_group", t("decidim.proposals.application_helper.filter_origin_values.user_groups")) if current_organization.user_groups_enabled?
        origin_values << TreePoint.new("meeting", t("decidim.proposals.application_helper.filter_origin_values.meetings"))

        TreeNode.new(
          TreePoint.new("", t("decidim.proposals.application_helper.filter_origin_values.all")),
          origin_values
        )
      end
    end
  end
end
