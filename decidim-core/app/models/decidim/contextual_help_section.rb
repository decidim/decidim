# frozen_string_literal: true

module Decidim
  class ContextualHelpSection < ApplicationRecord
    include Decidim::TranslatableResource
    include Decidim::Traceable

    translatable_fields :content

    belongs_to :organization, class_name: "Decidim::Organization"
    validates :content, presence: true

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::ContextualHelpSectionPresenter
    end

    # Public: Finds content given an id
    #
    # organization - The Organization to scope the content to
    # id - A String with the id
    #
    # Returns a Hash with the localized content
    def self.find_content(organization, id)
      find_by(organization:, section_id: id).try(:content) || {}
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
        organization:,
        section_id: id
      )

      if content.present? && content.values.any?(&:present?)
        item.update!(content:)
      else
        item.destroy!
      end

      content
    end
  end
end
