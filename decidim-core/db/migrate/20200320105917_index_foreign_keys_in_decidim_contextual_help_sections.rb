# frozen_string_literal: true

class IndexForeignKeysInDecidimContextualHelpSections < ActiveRecord::Migration[5.2]
  def change
    add_index :decidim_contextual_help_sections, :section_id
  end
end
