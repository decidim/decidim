# frozen_string_literal: true

class RemoveShowStatisticsFromDecidimParticipatoryProcesses < ActiveRecord::Migration[7.0]
  def up
    remove_column :decidim_participatory_processes, :show_statistics
  end

  def down
    add_column :decidim_participatory_processes, :show_statistics, :boolean, default: true
  end
end
