# frozen_string_literal: true

module Decidim
  module Amendable
    # This cell renders the button to amend the given resource.
    class AmendButtonCardCell < Decidim::ViewModel
      delegate :current_user, to: :controller, prefix: false

      def model_name
        model.model_name.human
      end

      def current_component
        model.component
      end

      def new_amend_path
        decidim.new_amend_path(amendable_gid: model.to_sgid.to_s)
      end

      def new_amend_button_label
        t("button", scope: "decidim.amendments.amendable", model_name:)
      end

      def new_amend_help_text
        content_tag :small do
          t("help_text",
            scope: "decidim.amendments.amendable",
            model_name: model_name.downcase,
            amendable_fields: model.amendable_fields.to_sentence)
        end
      end

      def button_classes
        "amend_button_card_cell button hollow expanded button--icon button--sc"
      end
    end
  end
end
