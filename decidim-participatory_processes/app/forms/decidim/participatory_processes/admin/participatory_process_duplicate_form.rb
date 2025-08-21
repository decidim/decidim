# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A form object used to duplicate a participatory processes from the admin
      # dashboard.
      #
      class ParticipatoryProcessDuplicateForm < Form
        include TranslatableAttributes

        translatable_attribute :title, String

        mimic :participatory_process

        attribute :slug, String
        attribute :duplicate_steps, Boolean
        attribute :duplicate_components, Boolean
        attribute :duplicate_landing_page_blocks, Boolean

        validates :slug, presence: true, format: { with: Decidim::ParticipatoryProcess.slug_format }
        validates :title, translatable_presence: true
        validate :slug_uniqueness

        private

        def slug_uniqueness
          return unless OrganizationParticipatoryProcesses.new(current_organization).query.where(slug:).where.not(id:).any?

          errors.add(:slug, :taken)
        end
      end
    end
  end
end
