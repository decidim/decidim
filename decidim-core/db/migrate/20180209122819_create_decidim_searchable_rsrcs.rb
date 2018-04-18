# frozen_string_literal: true

class CreateDecidimSearchableRsrcs < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_searchable_rsrcs do |t|
      t.text :content_a
      t.text :content_b
      t.text :content_c
      t.text :content_d
      t.string :locale, null: false
      t.datetime :datetime

      t.belongs_to :decidim_scope
      t.belongs_to :decidim_participatory_space, polymorphic: true, index: { name: "idx_decidim_schbl_rsrcs_on_ptcptry_spc_type_and_ptcptry_spc_id" }
      t.belongs_to :decidim_organization

      t.belongs_to :resource, polymorphic: true, index: { name: "idx_decidim_schbl_rsrcs_on_schbl_type_and_schbl_id" }
      t.timestamps null: false
    end
  end
end
