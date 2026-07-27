# frozen_string_literal: true

class ResetQuestionnaireCounters < ActiveRecord::Migration[8.1]
  def up
    Decidim::Forms::Questionnaire.find_each do |questionnaire|
      Decidim::Forms::Questionnaire.reset_counters(questionnaire.id, :responses)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
