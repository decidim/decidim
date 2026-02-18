# frozen_string_literal: true

class MoveAnnouncementToContentBlockOnParticipatoryProcesses < ActiveRecord::Migration[7.2]
  class ParticipatoryProcess < ApplicationRecord
    self.table_name = "decidim_participatory_processes"
  end

  class ContentBlock < ApplicationRecord
    self.table_name = "decidim_content_blocks"
  end

  def up
    ParticipatoryProcess.find_each do |participatory_process|
      announcement = participatory_process.announcement
      next if announcement.blank? || announcement == {}

      content_block = ContentBlock.find_or_initialize_by(
        decidim_organization_id: participatory_process.decidim_organization_id,
        scope_name: :participatory_process_homepage,
        manifest_name: :announcement,
        scoped_resource_id: participatory_process.id
      )

      settings = announcement.each_with_object({}) do |(locale, value), acc|
        next if locale.to_s == "machine_translations"

        acc["announcement_#{locale}"] = value
      end

      next if settings.empty?

      content_block.settings = (content_block.settings || {}).merge(settings)
      content_block.save!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
