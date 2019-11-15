# frozen_string_literal: true

class AddRichTextEditorForParticipantsToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_organizations,
               :rich_text_editor_for_participants,
               :boolean,
               default: false
  end
end
