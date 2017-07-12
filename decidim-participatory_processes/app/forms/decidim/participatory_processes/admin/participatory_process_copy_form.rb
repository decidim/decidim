# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
  module Admin
    # A form object used to copy a participatory processes from the admin
    # dashboard.
    #
    class ParticipatoryProcessCopyForm < Form
      include TranslatableAttributes

      translatable_attribute :title, String

      mimic :participatory_process

      attribute :slug, String
      attribute :copy_steps, Boolean
      attribute :copy_categories, Boolean
      attribute :copy_features, Boolean

      validates :slug, presence: true
      validates :title, translatable_presence: true
      validate :slug, :slug_uniqueness

      private

      def slug_uniqueness
        return unless OrganizationParticipatoryProcesses.new(current_organization).query.where(slug: slug).where.not(id: id).any?

        errors.add(:slug, :taken)
      end
    end
  end
  end
end
