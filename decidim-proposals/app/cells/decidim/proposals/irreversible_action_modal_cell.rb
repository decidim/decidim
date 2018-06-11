# frozen_string_literal: true

module Decidim
  module Proposals
    # This cell renders specific _partials_ for the `terms_and_conditions` StaticPage
    # the `model` is the partial to render
    # - :announcement, the TOS updated announcement when redirected to the TOS page.
    # - :sticky_form, the Accept updated TOS form in the TOS page.
    # - :refuse_btn_modal, the Modal with info when refusing the updated TOS.
    class IrreversibleActionModalCell < Decidim::ViewModel
      # include Decidim::SanitizeHelper
      # include Cell::ViewModel::Partial

      #delegate :current_user, to: :controller, prefix: false

      def show
        # return if model.nil?
        # return unless current_user
        # return if current_user.tos_accepted?
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
        label = t(action, scope:"decidim.proposals.collaborative_drafts.show")
        css = publish? ? "button expanded button--sc" : "secondary"

        button_tag label, type: "button", class: css, data: data
      end

      def modal_title
        t("title", scope:"decidim.proposals.collaborative_drafts.collaborative_draft.#{action}.irreversible_action_modal")
      end

      def modal_body
        t("body", scope:"decidim.proposals.collaborative_drafts.collaborative_draft.#{action}.irreversible_action_modal")
      end

      def button_continue
        label = t("ok", scope:"decidim.proposals.collaborative_drafts.collaborative_draft.#{action}.irreversible_action_modal")
        path = resource_path + "/#{action}"
        css = "button button--nomargin small"
        button_to label, path, class: css
      end

      def close_label
        t("cancel", scope:"decidim.proposals.collaborative_drafts.collaborative_draft.#{action}.irreversible_action_modal")
      end

      def resource_path
        resource_locator(model).path
      end
    end
  end
end
