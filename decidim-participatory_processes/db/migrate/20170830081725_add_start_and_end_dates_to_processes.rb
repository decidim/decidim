# frozen_string_literal: true

class AddStartAndEndDatesToProcesses < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_participatory_processes, :starts_at, :date
    add_column :decidim_participatory_processes, :ends_at, :date
  end
end
