# frozen_string_literal: true

class CreateAssemblyParticipatoryProcess < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_assembly_participatory_processes do |t|
      t.integer :decidim_assembly_id, foreign_key: true, index: { name: "index_decidim_assembly_id" }
      t.integer :decidim_participatory_process_id, foreign_key: true, index: { name: "index_decidim_participatory_process_id" }

      t.timestamps
    end
  end
end
