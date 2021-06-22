# frozen_string_literal: true

class AddAnnouncementToAssemblies < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_assemblies, :announcement, :jsonb
  end
end
