# frozen_string_literal: true

class AddDeletedAtToDecidimParticipatoryProcesses < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_participatory_processes, :deleted_at, :datetime
    add_index :decidim_participatory_processes, :deleted_at
  end
end
