# frozen_string_literal: true

module Decidim
  module Proposals
    # This cell renders the button and modal for the publish/withdraw
    # actions in the details of a collaborative draft
    # the `cell` should be called with an :action argument, to show relative info:
    # - :publish
    # - :withdraw
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

      def withdraw?
        action == :withdraw
      end

      def modal_id
        @modal_id ||= "#{SecureRandom.uuid}-#{action}-irreversible-action-modal"
      end

      def button_reveal_modal
        data = { "dialog-open": modal_id }
        label = t(action, scope: "decidim.proposals.collaborative_drafts.show")
        css = publish? ? "button button__lg button__secondary w-full" : "text-secondary"

        button_tag label, type: "button", class: css, data:
      end

      def modal_title
        t("title", scope: "decidim.proposals.collaborative_drafts.collaborative_draft.#{action}.irreversible_action_modal")
      end

      def modal_body
        t("body", scope: "decidim.proposals.collaborative_drafts.collaborative_draft.#{action}.irreversible_action_modal")
      end

      def button_continue
        label = t("ok", scope: "decidim.proposals.collaborative_drafts.collaborative_draft.#{action}.irreversible_action_modal")
        path = resource_path action
        css = "button button__lg button__secondary"
        button_to label, path, class: css
      end

      def close_label
        t("cancel", scope: "decidim.proposals.collaborative_drafts.collaborative_draft.#{action}.irreversible_action_modal")
      end

      def button_cancel
        button_tag type: "button", class: "button button__lg button__transparent-secondary", "data-dialog-close": modal_id do
          close_label
        end
      end

      def resource_path(action)
        @resource_path ||= decidim_proposals.send("#{action}_collaborative_draft_path",
                                                  id: model.id)
      end

      def decidim_proposals
        Decidim::EngineRouter.main_proxy(model.component)
      end
    end
  end
end
