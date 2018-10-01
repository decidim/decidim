# frozen_string_literal: true

module Decidim
  # This cell is used to render public activities performed by users.
  #
  # Each model that we want to represent should inherit from this cell and
  # tweak the necessary methods (usually `title` is enough).
  class ActivityCell < Decidim::ViewModel
    include Cell::ViewModel::Partial
    include Decidim::IconHelper
    include Decidim::ApplicationHelper

    def show
      return unless renderable?
      render
    end

    # Since activity logs could be linked to resource no longer available
    # this method is added in order to skip rendering a cell if there's
    # not enough data.
    def renderable?
      resource.present? && participatory_space.present?
    end

    # The resource linked to the activity.
    def resource
      model.resource_lazy
    end

    # The title to show at the card.
    #
    # The card will also be displayed OK if there's no title.
    def title
      translated_attribute(resource.title)
    end

    # The link to the resource linked to the activity.
    def resource_link_path
      resource_locator(resource).path
    end

    # The text to show as the link to the resource.
    def resource_link_text
      translated_attribute(resource.title)
    end

    private

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
