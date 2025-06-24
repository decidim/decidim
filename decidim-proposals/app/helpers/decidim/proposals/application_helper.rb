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

      # Public: The state of a proposal in a way a human can understand.
      #
      # state - The String state of the proposal.
      #
      # Returns a String.
      def humanize_proposal_state(state)
        I18n.t(state, scope: "decidim.proposals.answers", default: :not_answered)
      end

      def proposal_state_css_style(proposal)
        return "" if proposal.emendation?
        return "" if proposal.withdrawn?

        proposal.proposal_state&.css_style
      end

      # Public: The css class applied based on the proposal state.
      #
      # proposal - The proposal to evaluate.
      #
      # Returns a String.
      def proposal_state_css_class(proposal)
        return "alert" if proposal.withdrawn?
        return if proposal.state.blank?

        case proposal.state
        when "accepted"
          "success"
        when "rejected", "withdrawn"
          "alert"
        when "evaluating"
          "warning"
        else
          "info"
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

      def not_from_collaborative_draft(proposal)
        proposal.linked_resources(:proposals, "created_from_collaborative_draft").empty?
      end

      def not_from_participatory_text(proposal)
        proposal.participatory_text_level.nil?
      end

      # If the proposal is official or the rich text editor is enabled on the
      # frontend, the proposal body is considered as safe content; that is unless
      # the proposal comes from a collaborative_draft or a participatory_text.
      def safe_content?
        (rich_text_editor_in_public_views? && not_from_collaborative_draft(@proposal)) ||
          safe_content_admin?
      end

      # For admin entered content, the proposal body can contain certain extra
      # tags, such as iframes.
      def safe_content_admin?
        (@proposal.official? || @proposal.official_meeting?) && not_from_participatory_text(@proposal)
      end

      # If the content is safe, HTML tags are sanitized, otherwise, they are stripped.
      def render_proposal_body(proposal)
        sanitized = render_sanitized_content(proposal, :body)
        if safe_content?
          Decidim::ContentProcessor.render_without_format(sanitized).html_safe
        else
          Decidim::ContentProcessor.render(sanitized)
        end
      end

      # Returns :text_area or :editor based on the organization' settings.
      def text_editor_for_proposal_body(form)
        options = {
          class: "js-hashtags",
          hashtaggable: true,
          value: form_presenter.body(extras: false, strip_tags: !current_organization.rich_text_editor_in_public_views).strip
        }

        text_editor_for(form, :body, options)
      end

      def proposal_limit
        return if component_settings.proposal_limit.zero?

        component_settings.proposal_limit
      end

      def layout_item_classes
        if show_voting_rules?
          "layout-item lg:pt-4"
        else
          "layout-item"
        end
      end

      def show_voting_rules?
        return false if !votes_enabled? || votes_blocked?

        return true if vote_limit_enabled?
        return true if threshold_per_proposal_enabled?
        return true if proposal_limit_enabled?
        return true if can_accumulate_votes_beyond_threshold?
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
          ["all", t("decidim.proposals.proposals.filters.all")],
          ["my_proposals", t("decidim.proposals.proposals.filters.my_proposals")]
        ]
        base += [["voted", t("decidim.proposals.proposals.filters.voted")]] if current_settings.votes_enabled?
        base
      end

      # Explicitly commenting the used I18n keys so their are not flagged as unused
      # i18n-tasks-use t('decidim.proposals.application_helper.filter_origin_values.official')
      # i18n-tasks-use t('decidim.proposals.application_helper.filter_origin_values.participants')
      # i18n-tasks-use t('decidim.proposals.application_helper.filter_origin_values.user_groups')
      # i18n-tasks-use t('decidim.proposals.application_helper.filter_origin_values.official')
      # i18n-tasks-use t('decidim.proposals.application_helper.filter_origin_values.meetings')
      # i18n-tasks-use t('decidim.proposals.application_helper.filter_origin_values.all')
      def filter_origin_values
        scope = "decidim.proposals.application_helper.filter_origin_values"
        origin_values = []
        origin_values << TreePoint.new("official", t("official", scope:)) if component_settings.official_proposals_enabled
        origin_values << TreePoint.new("participants", t("participants", scope:))
        origin_values << TreePoint.new("user_group", t("user_groups", scope:)) if current_organization.user_groups_enabled?
        origin_values << TreePoint.new("meeting", t("meetings", scope:))

        TreeNode.new(
          TreePoint.new("", t("all", scope:)),
          origin_values
        )
      end

      def filter_proposals_state_values
        Decidim::CheckBoxesTreeHelper::TreeNode.new(
          Decidim::CheckBoxesTreeHelper::TreePoint.new("", t("decidim.proposals.application_helper.filter_state_values.all")),
          [
            Decidim::CheckBoxesTreeHelper::TreePoint.new("state_not_published", t("decidim.proposals.application_helper.filter_state_values.not_answered"))
          ] +
            Decidim::Proposals::ProposalState.where(component: current_component).where.not(token: "not_answered").map do |state|
              Decidim::CheckBoxesTreeHelper::TreePoint.new(state.token, translated_attribute(state.title))
            end
        )
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      def filter_sections
        @filter_sections ||= begin
          items = []
          if component_settings.proposal_answering_enabled && current_settings.proposal_answering_enabled
            items.append(method: :with_any_state, collection: filter_proposals_state_values, label: t("decidim.proposals.proposals.filters.state"), id: "state")
          end
          current_component.available_taxonomy_filters.each do |taxonomy_filter|
            items.append(method: "with_any_taxonomies[#{taxonomy_filter.root_taxonomy_id}]",
                         collection: filter_taxonomy_values_for(taxonomy_filter),
                         label: decidim_sanitize_translated(taxonomy_filter.name),
                         id: "taxonomy-#{taxonomy_filter.root_taxonomy_id}")
          end
          if component_settings.official_proposals_enabled
            items.append(method: :with_any_origin, collection: filter_origin_values, label: t("decidim.proposals.proposals.filters.origin"), id: "origin")
          end
          if current_user
            items.append(method: :activity, collection: activity_filter_values, label: t("decidim.proposals.proposals.filters.activity"), id: "activity", type: :radio_buttons)
          end
          if @proposals.only_emendations.any?
            items.append(method: :type, collection: filter_type_values, label: t("decidim.proposals.proposals.filters.amendment_type"), id: "amendment_type", type: :radio_buttons)
          end
          if linked_classes_for(Decidim::Proposals::Proposal).any?
            items.append(
              method: :related_to,
              collection: linked_classes_filter_values_for(Decidim::Proposals::Proposal),
              label: t("decidim.proposals.proposals.filters.related_to"),
              id: "related_to",
              type: :radio_buttons
            )
          end
        end
        # rubocop:enable Metrics/CyclomaticComplexity
        items.reject { |item| item[:collection].blank? }
      end

      def component_name
        i18n_key = controller_name == "collaborative_drafts" ? "decidim.proposals.collaborative_drafts.name" : "decidim.components.proposals.name"
        (defined?(current_component) && translated_attribute(current_component&.name).presence) || t(i18n_key)
      end

      def templates_available?
        Decidim.module_installed?(:templates) && defined?(Decidim::Templates::Template) && Decidim::Templates::Template.exists?(templatable: current_component)
      end
    end
  end
end
