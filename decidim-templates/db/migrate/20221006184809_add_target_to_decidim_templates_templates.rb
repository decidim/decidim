# frozen_string_literal: true

class AddTargetToDecidimTemplatesTemplates < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_templates_templates, :target, :string
  end
end
