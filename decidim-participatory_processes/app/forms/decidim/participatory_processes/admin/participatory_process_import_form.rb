# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A form object used to import a participatory processes from the admin
      # dashboard.
      #
      class ParticipatoryProcessImportForm < Form
        include TranslatableAttributes

        translatable_attribute :title, String

        mimic :participatory_process

        attribute :slug, String
        attribute :import_steps, Boolean
        attribute :import_categories, Boolean
        attribute :import_attachments, Boolean
        attribute :import_components, Boolean
        attribute :document

        validates :document, presence: true

        validates :slug, presence: true, format: { with: Decidim::ParticipatoryProcess.slug_format }
        validates :title, translatable_presence: true
        validate :slug_uniqueness

        def document_text
          @document_text ||= document&.read
        end

        private

        def slug_uniqueness
          return unless OrganizationParticipatoryProcesses.new(current_organization).query.where(slug: slug).where.not(id: id).any?

          errors.add(:slug, :taken)
        end
      end
    end
  end
end
