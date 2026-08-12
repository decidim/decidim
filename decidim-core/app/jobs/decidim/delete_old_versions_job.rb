# frozen_string_literal: true

module Decidim
  # A job to delete version data for old records. Extend this class and define
  # the item type for deletion within the class with:
  #   item_type "Decidim::TargetRecord"
  class DeleteOldVersionsJob < ApplicationJob
    class << self
      def item_type(*values)
        if values.present?
          @item_type = values
        else
          @item_type
        end
      end
    end

    def perform(cutoff_days)
      cutoff_date = Time.current - cutoff_days.days

      versions = PaperTrail::Version.where(
        item_type: self.class.item_type,
        created_at: ...cutoff_date
      )
      versions = versions.where(item_id: include_records) if respond_to?(:include_records, true)
      versions = versions.where.not(item_id: exclude_records) if respond_to?(:exclude_records, true)

      versions.delete_all
    end
  end
end
