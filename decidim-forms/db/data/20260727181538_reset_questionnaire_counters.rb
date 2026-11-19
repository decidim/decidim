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
      # Lock the questionnaire row and keep the lock until the counter is written. Without the
      # lock, a concurrent counter-cache update on the same row could commit between the count
      # and the write, and this absolute write would overwrite it with a stale value.
      questionnaire.with_lock do
        count = Response.where(decidim_questionnaire_id: questionnaire.id).count
        questionnaire.update_column(:responses_count, count) # rubocop:disable Rails/SkipsModelValidations
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
