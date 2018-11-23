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
      button_content = icon "thumb-down"
      button_content += t(:button_reject, scope: "decidim.amendments.emendation.actions")
      button_class = "button alert hollow expanded button--icon button--sc"

      decidim_form_for(model, url: decidim.reject_amend_path(amendment)) do |form|
        form.hidden_field :id
        button_tag type: "submit", class: button_class, data: { disable: true } do
          button_content
        end
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
