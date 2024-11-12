# frozen_string_literal: true

class RemoveColumnShowMetricsFromParticipatoryProcesses < ActiveRecord::Migration[7.0]
  def change
    remove_column :decidim_participatory_processes, :show_metrics, :boolean
  end
end
