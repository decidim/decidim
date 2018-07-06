# frozen_string_literal: true

class CreateDecidimMetrics < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_metrics do |t|
      t.date :day
      t.string :metric_type
      t.integer :cumulative
      t.integer :quantity
      t.references :decidim_category
      t.references :participatory_space, polymorphic: true, index: { name: "index_metric_on_participatory_space_id_and_type" }
      t.references :related_object, polymorphic: true, index: { name: "index_metric_on_related_object_id_and_type" }
      t.references :decidim_organization, index: true
    end
  end
end
