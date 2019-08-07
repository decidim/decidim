# frozen_string_literal: true

class CreateDecidimSearchableResource < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_searchable_resources do |t|
      t.text :content_a
      t.text :content_b
      t.text :content_c
      t.text :content_d
      t.string :locale, null: false
      t.datetime :datetime

      t.belongs_to :decidim_scope
      t.belongs_to :decidim_participatory_space, polymorphic: true, index: { name: "index_decidim_searchable_resource_on_pspace_type_and_pspace_id" }
      t.belongs_to :decidim_organization

      t.belongs_to :resource, polymorphic: true, index: { name: "index_decidim_searchable_rsrcs_on_s_type_and_s_id" }
      t.timestamps null: false
    end
  end
end
