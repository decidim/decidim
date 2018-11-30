# frozen_string_literal: true

module Decidim::Amendable
  # This cell renders the action buttons for coauthors to amend the given resource.
  class EmendationActionsCell < Decidim::ViewModel
    include Decidim::LayoutHelper

    private

    def emendation
      model.emendation
    end

    def amendment
      model.amendment
    end

    def accept_button
      link_content = icon "thumb-up"
      link_content += t(:button_accept, scope: "decidim.amendments.emendation.actions")
      link_class = "button success hollow expanded button--icon button--sc"

      link_to decidim.review_amend_path(amendment), class: link_class do
        link_content
      end
    end

    def reject_button
      link_to "#reject", class: "button alert hollow expanded button--icon button--sc" do
        content = icon "thumb-down"
        content += t(:button_reject, scope: "decidim.amendments.emendation.actions")
        content
      end
    end

    def help_text
      content_tag :small do
        t(:help_text, scope: "decidim.amendments.emendation.actions")
      end
    end

    def decidim
      Decidim::Core::Engine.routes.url_helpers
    end
  end
end
