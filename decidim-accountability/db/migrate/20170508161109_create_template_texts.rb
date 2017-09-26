# frozen_string_literal: true

class CreateTemplateTexts < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_accountability_template_texts do |t|
      t.jsonb :intro
      t.jsonb :categories_label
      t.jsonb :subcategories_label
      t.jsonb :heading_parent_level_results
      t.jsonb :heading_leaf_level_results
      t.references :decidim_feature, index: { name: :decidim_accountability_template_texts_on_feature_id }

      t.timestamps
    end
  end
end
