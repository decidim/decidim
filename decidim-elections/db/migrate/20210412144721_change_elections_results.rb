# frozen_string_literal: true

class ChangeElectionsResults < ActiveRecord::Migration[5.2]
  def change
    change_table :decidim_elections_results do |t|
      t.rename :votes_count, :value
      t.remove_belongs_to :decidim_elections_answer
      t.remove_belongs_to :decidim_votings_polling_station

      t.integer :result_type, index: true

      t.belongs_to :closurable,
                   null: false,
                   polymorphic: true,
                   index: false
      t.belongs_to :decidim_elections_answer,
                   null: true,
                   index: false
      t.belongs_to :decidim_elections_question,
                   null: true,
                   index: false
    end
  end
end
