# frozen_string_literal: true

module Decidim
  # This cell renders the button to amend the given resource.
  class AmendButtonCardCell < Decidim::ViewModel
    include LayoutHelper

    private

    def model_name
      model.model_name.human
    end

    def current_user
      context[:current_user]
    end

    def current_component
      model.component
    end

    def decidim
      Decidim::Core::Engine.routes.url_helpers
    end

    def button_classes
      "button secondary hollow expanded button--icon button--sc"
    end
  end
end
