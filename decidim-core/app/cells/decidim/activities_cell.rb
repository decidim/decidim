# frozen_string_literal: true

module Decidim
  class ActivitiesCell < Decidim::ViewModel
    include Decidim::CardHelper
    include Decidim::IconHelper
    include Decidim::Core::Engine.routes.url_helpers

    delegate :current_organization, to: :controller

    def show
      return if activities.blank?

      activities.map do |activity|
        activity.organization_lazy
        activity.resource_lazy
        activity.participatory_space_lazy
        activity.component_lazy
      end

      render
    end

    def activities
      model
    end
  end
end
