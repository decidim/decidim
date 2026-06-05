# frozen_string_literal: true

module Decidim
  class RemoveSearchIndexesJob < ApplicationJob
    queue_as :default

    def perform(elements)
      elements.each do |element|
        element.remove_from_index(element)
        next unless element.respond_to?(:comments)

        element.comments.each do |comment|
          Decidim::RemoveSearchIndexesJob.perform_later([comment])
        end
      end
    end
  end
end
