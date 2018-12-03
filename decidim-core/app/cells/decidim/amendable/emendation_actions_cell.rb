# frozen_string_literal: true

module Decidim::Amendable
  # This cell renders the action buttons for coauthors to amend the given resource.
  class EmendationActionsCell < Decidim::ViewModel
    include Decidim::LayoutHelper

    delegate :amendment, to: :model

    def current_component
      model.component
    end

    def review_amend_path
      decidim.review_amend_path(amendment)
    end

    def accept_button_classes
      "button success hollow expanded button--icon button--sc"
    end

    def accept_button_label
      content = icon "thumb-up"
      content += t(:button_accept, scope: "decidim.amendments.emendation.actions")
      content
    end

    def reject_amend_path
      decidim.reject_amend_path(amendment)
    end

    def reject_button_classes
      "button alert hollow expanded button--icon button--sc"
    end

    def reject_button_label
      content = icon "thumb-down"
      content += t(:button_reject, scope: "decidim.amendments.emendation.actions")
      content
    end

    def accept_reject_help_text
      content_tag :small do
        t(:help_text, scope: "decidim.amendments.emendation.actions")
      end
    end

    def decidim
      Decidim::Core::Engine.routes.url_helpers
    end
  end
end
