# frozen_string_literal: true

module Decidim
  class ContextualHelpSection < ApplicationRecord
    belongs_to :organization, class_name: "Decidim::Organization"
    validates :organization, presence: true
    validates :content, presence: true

    # Public: Finds content given an id
    #
    # organization - The Organization to scope the content to
    # id - A String with the id
    #
    # Returns a Hash with the localized content
    def self.find_content(organization, id)
      find_by(organization: organization, section_id: id).try(:content) || {}
    end

    # Public: Stores the content.
    #
    # organization - The Organization to scope the content to
    # id           - A String with the id
    # content      - A Hash with the content to store
    #
    # Returns a Hash with the localized content
    def self.set_content(organization, id, content)
      item = find_or_initialize_by(
        organization: organization,
        section_id: id
      )

      if content.present? && content.values.any?(&:present?)
        item.update!(content: content)
      else
        item.destroy!
      end

      content
    end
  end
end
