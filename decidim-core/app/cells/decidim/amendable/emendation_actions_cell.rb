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

    def reject_amend_path
      decidim.reject_amend_path(amendment)
    end

    def decidim
      Decidim::Core::Engine.routes.url_helpers
    end
  end
end
