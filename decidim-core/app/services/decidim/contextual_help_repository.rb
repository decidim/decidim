# frozen_string_literal: true

module Decidim
  class ContextualHelpRepository
    def initialize(organization)
      @organization = organization
    end

    def find(id)
      @help_element = HelpElement.find_by(
        organization: @organization,
        section_id: id
      )

      @help_element.try(:content) || {}
    end

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
