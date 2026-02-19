# frozen_string_literal: true

class MoveAnnouncementToContentBlockOnAssemblies < ActiveRecord::Migration[7.2]
  class Assembly < ApplicationRecord
    self.table_name = "decidim_assemblies"
  end

  class ContentBlock < ApplicationRecord
    self.table_name = "decidim_content_blocks"
  end

  def up
    Assembly.find_each do |assembly|
      announcement = assembly.announcement
      next if announcement.blank? || announcement == {}

      content_block = ContentBlock.find_or_initialize_by(
        decidim_organization_id: assembly.decidim_organization_id,
        scope_name: :assembly_homepage,
        manifest_name: :announcement,
        scoped_resource_id: assembly.id
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
