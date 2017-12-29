# This migration comes from decidim_participatory_processes (originally 20170404132616)
# frozen_string_literal: true

class ChangeStepsEndAndStartDateToDate < ActiveRecord::Migration[5.0]
  def change
    change_column :decidim_participatory_process_steps, :start_date, :date
    change_column :decidim_participatory_process_steps, :end_date, :date
  end
end
