# frozen_string_literal: true

module Decidim
  module Proposals
    # This cell renders the button and modal for the publish/close
    # actions in the details of a collaborative draft
    # the `cell` should be called with an :action argument, to show relative info:
    # - :publish
    # - :close
    class IrreversibleActionModalCell < Decidim::ViewModel
      def show
        return unless action.presence
        render :show
      end

      private

      def action
        options[:action]
      end

      def publish?
        action == :publish
      end

      def close?
        action == :close
      end

      def modal_id
        "#{action}-irreversible-action-modal"
      end

      def button_reveal_modal
        data = { open: modal_id }
        label = t(action, scope: "decidim.proposals.collaborative_drafts.show")
        css = publish? ? "button expanded button--sc" : "secondary"

        button_tag label, type: "button", class: css, data: data
      end

      def modal_title
        t("title", scope: "decidim.proposals.collaborative_drafts.collaborative_draft.#{action}.irreversible_action_modal")
      end

      def modal_body
        t("body", scope: "decidim.proposals.collaborative_drafts.collaborative_draft.#{action}.irreversible_action_modal")
      end

      def button_continue
        label = t("ok", scope: "decidim.proposals.collaborative_drafts.collaborative_draft.#{action}.irreversible_action_modal")
        path = resource_path + "/#{action}"
        css = "button expanded"
        button_to label, path, class: css
      end

      def close_label
        t("cancel", scope: "decidim.proposals.collaborative_drafts.collaborative_draft.#{action}.irreversible_action_modal")
      end

      def resource_path
        resource_locator(model).path
      end
    end
  end
end
