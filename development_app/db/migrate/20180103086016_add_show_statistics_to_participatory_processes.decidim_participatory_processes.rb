# This migration comes from decidim_participatory_processes (originally 20170725085104)
# frozen_string_literal: true

class AddShowStatisticsToParticipatoryProcesses < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_participatory_processes, :show_statistics, :boolean, default: true
  end
end
