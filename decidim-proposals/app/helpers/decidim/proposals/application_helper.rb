# frozen_string_literal: true

module Decidim
  module Proposals
    # Custom helpers, scoped to the proposals engine.
    #
    module ApplicationHelper
      include Decidim::Comments::CommentsHelper
      include PaginateHelper
      include ProposalVotesHelper
      include ::Decidim::LikeableHelper
      include ::Decidim::FollowableHelper
      include Decidim::MapHelper
      include Decidim::Proposals::MapHelper
      include ControlVersionHelper
      include Decidim::RichTextEditorHelper
      include Decidim::CheckBoxesTreeHelper

      # Public: The status of a proposal in a way a human can understand.
      #
      # status - The String status of the proposal.
      #
      # Returns a String.
      def humanize_proposal_status(status)
        I18n.t(status, scope: "decidim.proposals.answers", default: :not_answered)
      end

      def proposal_status_css_style(proposal)
        return "" if proposal.emendation?
        return "" if proposal.withdrawn?

        proposal.proposal_status&.css_style
      end

      # Public: The css class applied based on the proposal status.
      #
      # proposal - The proposal to evaluate.
      #
      # Returns a String.
      def proposal_status_css_class(proposal)
        return "alert" if proposal.withdrawn?
        return if proposal.status.blank?

        case proposal.status
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

      def proposal_limit_enabled?
        proposal_limit.present?
      end

      def not_from_participatory_text(proposal)
        proposal.participatory_text_level.nil?
      end

      # If the proposal is official or the rich text editor is enabled on the
      # frontend, the proposal body is considered as safe content; that is unless
      # safe_content_admin? is used and the proposal comes from a participatory text.
      def safe_content?
        rich_text_editor_in_public_views? || safe_content_admin?
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
          value: form_presenter.body(strip_tags: !current_organization.rich_text_editor_in_public_views).strip,
          data: { controller: "character-counter" }
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
      # i18n-tasks-use t('decidim.proposals.application_helper.filter_origin_values.official')
      # i18n-tasks-use t('decidim.proposals.application_helper.filter_origin_values.meetings')
      # i18n-tasks-use t('decidim.proposals.application_helper.filter_origin_values.all')
      def filter_origin_values
        scope = "decidim.proposals.application_helper.filter_origin_values"
        origin_values = []
        origin_values << TreePoint.new("official", t("official", scope:)) if component_settings.official_proposals_enabled
        origin_values << TreePoint.new("participants", t("participants", scope:))
        origin_values << TreePoint.new("meeting", t("meetings", scope:))

        TreeNode.new(
          TreePoint.new("", t("all", scope:)),
          origin_values
        )
      end

      def filter_proposals_status_values
        Decidim::CheckBoxesTreeHelper::TreeNode.new(
          Decidim::CheckBoxesTreeHelper::TreePoint.new("", t("decidim.proposals.application_helper.filter_status_values.all")),
          [
            Decidim::CheckBoxesTreeHelper::TreePoint.new("status_not_published", t("decidim.proposals.application_helper.filter_status_values.not_answered"))
          ] +
            Decidim::Proposals::ProposalStatus.where(component: current_component).where.not(token: "not_answered").map do |status|
              Decidim::CheckBoxesTreeHelper::TreePoint.new(status.token, translated_attribute(status.title))
            end
        )
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      def filter_sections
        @filter_sections ||= begin
          items = []
          if component_settings.proposal_answering_enabled && current_settings.proposal_answering_enabled
            items.append(method: :with_any_status, name: "[with_any_status]", collection: filter_proposals_status_values, label: t("decidim.proposals.proposals.filters.status"),
                         id: "status")
          end
          current_component.available_taxonomy_filters.each do |taxonomy_filter|
            items.append(method: :with_any_taxonomies,
                         name: "[with_any_taxonomies][#{taxonomy_filter.root_taxonomy_id}]",
                         collection: filter_taxonomy_values_for(taxonomy_filter),
                         label: decidim_sanitize_translated(taxonomy_filter.name),
                         id: "taxonomy-#{taxonomy_filter.root_taxonomy_id}")
          end
          if component_settings.official_proposals_enabled
            items.append(method: :with_any_origin,
                         name: "[with_any_origin]",
                         collection: filter_origin_values,
                         label: t("decidim.proposals.proposals.filters.origin"),
                         id: "origin")
          end
          if current_user
            items.append(method: :activity,
                         name: "[activity]",
                         collection: activity_filter_values,
                         label: t("decidim.proposals.proposals.filters.activity"),
                         id: "activity",
                         type: :radio_buttons)
          end
          if @proposals.only_emendations.any?
            items.append(method: :type,
                         name: "[type]",
                         collection: filter_type_values,
                         label: t("decidim.proposals.proposals.filters.amendment_type"),
                         id: "amendment_type",
                         type: :radio_buttons)
          end
          if linked_classes_for(Decidim::Proposals::Proposal).any?
            items.append(
              method: :related_to,
              name: "[related_to]",
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
        i18n_key = "decidim.components.proposals.name"
        (defined?(current_component) && translated_attribute(current_component&.name).presence) || t(i18n_key)
      end

      def templates_available?
        Decidim.module_installed?(:templates) && defined?(Decidim::Templates::Template) && Decidim::Templates::Template.exists?(templatable: current_component)
      end
    end
  end
end
