# frozen_string_literal: true

module Decidim
  module Proposals
    # Custom helpers, scoped to the collaborative_draft resource.
    #
    module CollaborativeDraftHelper
      def filter_collaborative_drafts_state_values
        scope = "decidim.proposals.collaborative_drafts.filters"
        Decidim::CheckBoxesTreeHelper::TreeNode.new(
          Decidim::CheckBoxesTreeHelper::TreePoint.new("", t("all", scope:)),
          [
            Decidim::CheckBoxesTreeHelper::TreePoint.new("open", t("open", scope:)),
            Decidim::CheckBoxesTreeHelper::TreePoint.new("withdrawn", t("withdrawn", scope:)),
            Decidim::CheckBoxesTreeHelper::TreePoint.new("published", t("published", scope:))
          ]
        )
      end

      def humanize_collaborative_draft_state(state)
        I18n.t(state, scope: "decidim.proposals.collaborative_drafts.states", default: :open)
      end

      def collaborative_drafts_state_class(type)
        case type
        when "withdrawn"
          "alert"
        when "open", "published"
          "success"
        end
      end

      def accept_request_button_label
        t("accept_request", scope: "decidim.proposals.collaborative_drafts.requests.collaboration_requests")
      end

      def reject_request_button_label
        t("reject_request", scope: "decidim.proposals.collaborative_drafts.requests.collaboration_requests")
      end

      def collaborative_drafts_filter_sections
        @collaborative_drafts_filter_sections ||= begin
          items = [{
            method: :with_any_state,
            collection: filter_collaborative_drafts_state_values,
            label_scope: "decidim.proposals.collaborative_drafts.filters",
            id: "state"
          }]
          if current_component.has_subscopes?
            items.append(method: :with_any_scope, collection: filter_scopes_values, label_scope: "decidim.proposals.collaborative_drafts.filters", id: "scope")
          end
          if current_component.categories.any?
            items.append(method: :with_any_category, collection: filter_categories_values, label_scope: "decidim.proposals.collaborative_drafts.filters", id: "category")
          end
          if linked_classes_for(Decidim::Proposals::CollaborativeDraft).any?
            items.append(
              method: :related_to,
              collection: linked_classes_filter_values_for(Decidim::Proposals::CollaborativeDraft),
              label_scope: "decidim.proposals.collaborative_drafts.filters",
              id: "related_to",
              type: :radio_buttons
            )
          end
          items.reject { |item| item[:collection].blank? }
        end
      end
    end
  end
end
