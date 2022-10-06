# frozen_string_literal: true

module Decidim
  module Amendable
    # This cell renders the button to amend the given resource.
    class PromoteButtonCardCell < Decidim::ViewModel
      delegate :current_user, to: :controller, prefix: false

      def emendation
        @emendation ||= model
      end

      def model_name
        model.model_name.human
      end

      def current_component
        model.component
      end

      def promote_amend_path
        decidim.promote_amend_path(model.amendment)
      end

      def promote_amend_button_label
        t("promote_button", scope: "decidim.amendments.amendable", model_name:)
      end

      def promote_confirm_text
        t("promote_confirm_text", scope: "decidim.amendments.amendable")
      end

      def promote_amend_help_text
        content_tag :small do
          t("promote_help_text",
            scope: "decidim.amendments.amendable",
            model_name: model_name.downcase,
            amendable_fields: model.amendable_fields.to_sentence)
        end
      end

      def decidim
        Decidim::Core::Engine.routes.url_helpers
      end

      def button_classes
        "amend_button_card_cell button expanded button--icon button--sc"
      end
    end
  end
end
