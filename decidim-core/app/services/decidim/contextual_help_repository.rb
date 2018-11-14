# frozen_string_literal: true

module Decidim
  # This class holds the logic to retrieve and set contextual help content
  # that will be shown in different sections of the page.
  class ContextualHelpRepository
    # Initializes a repository with an organization.
    #
    # organization - The organization to scope the content to.
    def initialize(organization)
      @organization = organization
    end

    # Public: Finds content given an id
    #
    # id - A String with the id
    #
    # Returns a Hash with the localized content
    def find(id)
      @help_element = HelpElement.find_by(
        organization: @organization,
        section_id: id
      )

      @help_element.try(:content) || {}
    end

    # Public: Stores the content.
    #
    # id      - A String with the id
    # content - A Hash with the content to store
    #
    # Returns a Hash with the localized content
    def set(id, content)
      @help_element = HelpElement.find_or_initialize_by(
        organization: @organization,
        section_id: id
      )

      if content.present? && content.values.any?(&:present?)
        @help_element.update!(content: content)
      else
        @help_element.destroy!
      end

      content
    end
  end
end
