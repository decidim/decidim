# frozen_string_literal: true

module Decidim::Amendable
  # This cell renders the button to amend the given resource.
  class AmendmentsListCell < Decidim::ViewModel
    include Decidim::LayoutHelper
    include Decidim::CardHelper

    private

    def has_actions?
      false
    end

    def model_name
      model.model_name.human
    end

    def current_user
      context[:current_user]
    end

    def current_component
      model.first.component
    end

    def decidim
      Decidim::Core::Engine.routes.url_helpers
    end

  end
end
