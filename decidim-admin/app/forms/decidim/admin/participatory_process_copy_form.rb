# frozen_string_literal: true
module Decidim
  module Admin
    # A form object used to copy a participatory processes from the admin
    # dashboard.
    #
    class ParticipatoryProcessCopyForm < Form
      include TranslatableAttributes

      translatable_attribute :title, String

      attribute :slug, String
      attribute :copy_steps, Boolean
      attribute :copy_categories, Boolean
      attribute :copy_process_users, Boolean
      attribute :copy_moderations, Boolean
      attribute :copy_pages, Boolean
      attribute :copy_features, Boolean

      validates :slug, presence: true
      validates :title, translatable_presence: true
      validate :slug, :slug_uniqueness

      private

      def slug_uniqueness
        return unless current_organization.participatory_processes.where(slug: slug).where.not(id: id).any?

        errors.add(:slug, :taken)
      end
    end
  end
end
