# frozen_string_literal: true

module Decidim
  module Proposals
    # Simple helpers to handle markup variations for proposals
    module ProposalsHelper
      def proposal_reason_callout_announcement
        {
          title: translated_attribute(@proposal.proposal_state&.announcement_title),
          body: decidim_sanitize_editor_admin(translated_attribute(@proposal.answer))
        }
      end

      def proposal_has_costs?
        @proposal.cost.present?
      end

      def toggle_view_mode_link(current_mode, target_mode, title, params)
        path = proposals_path(params.permit(:order, filter: {}).merge({ view_mode: target_mode }))
        icon_name = target_mode == "grid" ? "layout-grid-fill" : "list-check"

        if current_mode == target_mode
          link_to path, remote: true, role: "button", "aria-current": true, title: do
            icon(icon_name, class: "view-icon", role: "img", "aria-hidden": true)
          end
        else
          link_to path, remote: true, role: "button", title: do
            icon(icon_name, class: "view-icon--disabled", role: "img", "aria-hidden": true)
          end
        end
      end

      def proposals_container_class(view_mode)
        view_mode == "grid" ? "card__grid-grid" : "card__list-list"
      end

      def card_size_for_view_mode(view_mode)
        view_mode == "grid" ? :g : nil
      end

      def resource_version(resource, options = {})
        return unless resource.respond_to?(:amendable?) && resource.amendable?

        super
      end
    end
  end
end
