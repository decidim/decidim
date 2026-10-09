# frozen_string_literal: true

class ResetQuestionnaireCounters < ActiveRecord::Migration[8.1]
  class Questionnaire < ApplicationRecord
    self.table_name = :decidim_forms_questionnaires
  end

  class Response < ApplicationRecord
    self.table_name = :decidim_forms_responses
  end

  def up
    Questionnaire.find_each do |questionnaire|
      questionnaire.update_column(:responses_count, Response.where(decidim_questionnaire_id: questionnaire.id).count) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
