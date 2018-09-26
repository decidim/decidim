# frozen_string_literal: true

module Decidim
  class ActivityCell < Decidim::ViewModel
    include Cell::ViewModel::Partial
    include Decidim::IconHelper
    include Decidim::ApplicationHelper

    def show
      return unless valid?
      render
    end

    def valid?
      resource.present? && participatory_space.present?
    end

    private

    def title
      translated_attribute(resource.title)
    end

    def activity_link_path
      resource_locator(resource).path
    end

    def activity_link_text
      translated_attribute(resource.title)
    end

    def resource
      model.resource_lazy
    end

    def component
      model.component_lazy
    end

    def organization
      model.organization_lazy
    end

    def user
      model.user_lazy
    end

    def participatory_space
      return resource if resource.is_a?(Decidim::Participable)

      model.participatory_space_lazy
    end

    def participatory_space_link
      link_to(
        translated_attribute(participatory_space.title),
        resource_locator(participatory_space).path
      )
    end
  end
end
