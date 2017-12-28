# This migration comes from decidim_participatory_processes (originally 20170830081725)
# frozen_string_literal: true

class AddStartDateToProcesses < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_participatory_processes, :start_date, :date
    ActiveRecord::Base.connection.execute("UPDATE decidim_participatory_processes SET start_date = created_at")
  end
end
