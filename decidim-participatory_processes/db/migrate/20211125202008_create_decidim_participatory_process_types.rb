# frozen_string_literal: true

class CreateDecidimParticipatoryProcessTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_participatory_process_types do |t|
      t.jsonb :title, null: false
      t.references(
        :decidim_organization,
        foreign_key: true,
        index: { name: "index_decidim_process_types_on_decidim_organization_id" }
      )
      t.timestamps
    end

    add_reference(
      :decidim_participatory_processes,
      :decidim_participatory_process_type,
      foreign_key: true,
      index: { name: "index_decidim_processes_on_decidim_process_type_id" }
    )
  end
end
