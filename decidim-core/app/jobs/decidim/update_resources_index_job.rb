# frozen_string_literal: true

module Decidim
  class UpdateResourcesIndexJob < ApplicationJob
    queue_as :default

    def perform(participatory_space)
      return if participatory_space.components.empty?

      child_resources = Decidim::ParticipatorySpaceResources.for(participatory_space)

      child_resources.each(&:try_update_index_for_search_resource)
    end
  end
end
