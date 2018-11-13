# frozen_string_literal: true

module Decidim
  class ContextualHelp
    include TranslationsHelper

    def initialize(organization)
      @organization = organization
    end

    def sections
      @sections ||= Decidim.participatory_space_manifests.map do |manifest|
        Section.new(
          id: "#{manifest.name}_index",
          name: multi_translation("activerecord.models.#{manifest.model_class_name.underscore}.other"),
          organization: @organization
        )
      end
    end

    def find(id)
      sections.find { |section| section.id == id.to_sym }
    end

    class Section
      include Virtus.model

      attribute :id, Symbol
      attribute :name, Hash
      attribute :organization, ActiveRecord::Base

      delegate :content, to: :help_element

      def content=(content)
        if content.present?
          help_element.update!(content: content)
        else
          help_element.destroy!
          @help_element = nil
        end
      end

      private

      def help_element
        @help_element = HelpElement.find_or_initialize_by(
          organization: organization,
          section_id: id
        )
      end
    end
  end
end
