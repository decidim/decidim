# frozen_string_literal: true

module Decidim
  class UpdateSearchIndexesJob < ApplicationJob
    queue_as :default

    def perform(elements, visited = [])
      elements.each { |element| element.try(:try_update_index_for_search_resource, visited) }
    end
  end
end
