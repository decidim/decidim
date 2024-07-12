# frozen_string_literal: true

class RemoveShowStatisticsFromDecidimAssemblies < ActiveRecord::Migration[7.0]
  def up
    remove_column :decidim_assemblies, :show_statistics
  end

  def down
    add_column :decidim_assemblies, :show_statistics, :boolean, default: false
  end
end
