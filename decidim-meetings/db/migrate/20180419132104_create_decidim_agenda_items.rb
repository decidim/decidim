# frozen_string_literal: true

class CreateDecidimAgendaItems < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_meetings_agenda_items do |t|
      t.references :decidim_agenda, index: true
      t.integer :position
      t.references :parent, index: true
      t.integer :duration
      t.jsonb :title
      t.jsonb :description

      t.timestamps
    end
  end
end
