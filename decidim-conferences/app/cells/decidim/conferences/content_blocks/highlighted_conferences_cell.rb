# frozen_string_literal: true

module Decidim
  module Conferences
    module ContentBlocks
      class HighlightedConferencesCell < Decidim::ViewModel
        include Decidim::Conferences::Engine.routes.url_helpers

        delegate :current_organization, to: :controller
        delegate :current_user, to: :controller

        def show
          render if highlighted_conferences.any?
        end

        def highlighted_conferences
          OrganizationPrioritizedConferences.new(current_organization, current_user)
        end

        def i18n_scope
          "decidim.conferences.pages.home.highlighted_conferences"
        end
      end
    end
  end
end
