# frozen_string_literal: true

class AddFieldValuesToDecidimTemplates < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_templates_templates, :field_values, :json, default: {}
    add_column :decidim_templates_templates, :target, :string
  end
end
