# frozen_string_literal: true

module Decidim
  class RemoveSearchIndexesJob < ApplicationJob
    queue_as :default

    def perform(elements)
      elements.each { |element| element.remove_from_index(element) }
    end
  end
end
