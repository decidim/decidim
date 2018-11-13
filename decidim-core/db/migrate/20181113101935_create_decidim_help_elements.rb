# frozen_string_literal: true

class CreateDecidimHelpElements < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_help_elements do |t|
      t.string :section_id, null: false
      t.references :organization, null: false
      t.jsonb :content, null: false
    end
  end
end
