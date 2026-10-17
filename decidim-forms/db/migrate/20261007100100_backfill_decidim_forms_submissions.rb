# frozen_string_literal: true

class BackfillDecidimFormsSubmissions < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  class Response < ApplicationRecord
    self.table_name = "decidim_forms_responses"
  end

  class Submission < ApplicationRecord
    self.table_name = "decidim_forms_submissions"
  end

  class Questionnaire < ApplicationRecord
    self.table_name = "decidim_forms_questionnaires"
  end

  def up
    report_ambiguous_groups

    questionnaire_ids_to_backfill.each_slice(100) do |ids|
      say_with_time "Backfilling submissions for questionnaires #{ids.first}..#{ids.last}" do
        execute insert_submissions_sql(ids)
        execute link_responses_sql(ids)
      end
    end

    report_unlinked_responses
  end

  def down
    Response.where.not(decidim_submission_id: nil).update_all(decidim_submission_id: nil) # rubocop:disable Rails/SkipsModelValidations
    Submission.delete_all
  end

  private

  def questionnaire_ids_to_backfill
    Response.where(decidim_submission_id: nil, decidim_questionnaire_id: Questionnaire.select(:id))
            .order(:decidim_questionnaire_id).distinct.pluck(:decidim_questionnaire_id)
  end

  def report_ambiguous_groups
    count = Response.where(decidim_submission_id: nil)
                    .group(:decidim_questionnaire_id, :session_token)
                    .having("COUNT(*) > COUNT(DISTINCT decidim_question_id)")
                    .count.size
    say "#{count} response groups contain more than one row per question; they are kept as is"
  end

  def report_unlinked_responses
    say "#{Response.where(decidim_submission_id: nil).count} responses without an existing questionnaire were left unlinked"
  end

  def insert_submissions_sql(ids)
    <<~SQL.squish
      INSERT INTO decidim_forms_submissions
        (decidim_questionnaire_id, session_token, decidim_user_id, ip_hash, created_at, updated_at)
      SELECT decidim_questionnaire_id, session_token, MAX(decidim_user_id), MAX(ip_hash), MIN(created_at), MAX(updated_at)
      FROM decidim_forms_responses
      WHERE decidim_submission_id IS NULL AND decidim_questionnaire_id IN (#{ids.join(",")})
      GROUP BY decidim_questionnaire_id, session_token
      ON CONFLICT (decidim_questionnaire_id, session_token) DO NOTHING
    SQL
  end

  def link_responses_sql(ids)
    <<~SQL.squish
      UPDATE decidim_forms_responses AS responses
      SET decidim_submission_id = submissions.id
      FROM decidim_forms_submissions AS submissions
      WHERE responses.decidim_submission_id IS NULL
        AND responses.decidim_questionnaire_id IN (#{ids.join(",")})
        AND submissions.decidim_questionnaire_id = responses.decidim_questionnaire_id
        AND submissions.session_token = responses.session_token
    SQL
  end
end
