# frozen_string_literal: true

class RemoveColumnShowStatisticsFromParticipatoryProcesses < ActiveRecord::Migration[7.0]
  def change
    remove_column :decidim_participatory_processes, :show_statistics, :string
  end
end
