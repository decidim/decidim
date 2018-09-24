# frozen_string_literal: true

module Decidim
  class ActivitiesCell < Decidim::ViewModel
    include Decidim::CardHelper
    include Decidim::IconHelper
    include Decidim::Core::Engine.routes.url_helpers

    delegate :current_organization, to: :controller

    def show
      return if resources.blank?
      render
    end

    def resources
      @resources ||= activities.group_by(&:resource_type).flat_map do |resource_type, activities|
        klass = resource_type.constantize
        if klass.include?(Decidim::HasComponent)
          klass
            .includes(:component)
            .where(id: activities.map(&:resource_id))
            .where.not(decidim_components: { published_at: nil })
        else
          klass.where(id: activities.map(&:resource_id))
        end
      end
    end

    def activities
      model
    end
  end
end
