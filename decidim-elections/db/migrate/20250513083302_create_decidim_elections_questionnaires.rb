# frozen_string_literal: true

class CreateDecidimElectionsQuestionnaires < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_elections_questionnaires do |t|
      t.references :questionnaire_for, polymorphic: true, index: { name: "index_elections_questionnaires_on_for_type_and_id" }

      t.timestamps
    end
  end
end
