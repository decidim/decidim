# frozen_string_literal: true

module Decidim
  class UpdateSearchIndexesJob < ApplicationJob
    queue_as :default

    def perform(elements)
      elements.each { |element| element.try(:try_update_index_for_search_resource) }
    end
  end
end
