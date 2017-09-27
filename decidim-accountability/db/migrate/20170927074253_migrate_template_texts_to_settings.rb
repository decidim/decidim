class MigrateTemplateTextsToSettings < ActiveRecord::Migration[5.1]
  class Feature < ApplicationRecord
    self.table_name = :decidim_features
  end

  def up
    template_texts = execute "SELECT * from decidim_accountability_template_texts"
    template_texts.each do |template_text|
      feature = Feature.find(template_text["decidim_feature_id"])
      feature.settings["global"].merge!(
        intro: template_text["intro"],
        categories_label: template_text["categories_label"],
        subcategories_label: template_text["subcategories_label"],
        heading_parent_level_results: template_text["heading_parent_level_results"],
        heading_leaf_level_results: template_text["heading_leaf_level_results"]
      )
      feature.save!
    end
    drop_table :decidim_accountability_template_texts
  end
end
