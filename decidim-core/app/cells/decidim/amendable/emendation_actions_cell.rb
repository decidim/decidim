# frozen_string_literal: true

module Decidim::Amendable
  # This cell renders the button to amend the given resource.
  class EmendationActionsCell < Decidim::ViewModel
    include Decidim::LayoutHelper

    private


    def accept_button
      link_to "#accept", class: "button success hollow expanded button--icon button--sc" do
        content = icon "thumb-up"
        content += t(:button_accept, scope: "decidim.amendments.emendation.actions")
        content
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
