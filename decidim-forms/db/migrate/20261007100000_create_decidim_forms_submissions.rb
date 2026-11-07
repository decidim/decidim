# frozen_string_literal: true

class CreateDecidimFormsSubmissions < ActiveRecord::Migration[8.1]
  def change
    create_table :decidim_forms_submissions do |t|
      t.references :decidim_questionnaire, null: false, type: :integer, index: false, foreign_key: { to_table: :decidim_forms_questionnaires }
      t.references :decidim_user, type: :integer, index: false
      t.string :session_token, null: false
      t.string :ip_hash
      t.timestamps
    end

    add_index :decidim_forms_submissions, [:decidim_questionnaire_id, :session_token], unique: true, name: "index_decidim_forms_submissions_on_questionnaire_and_token"
    add_index :decidim_forms_submissions, [:decidim_user_id, :decidim_questionnaire_id], name: "index_decidim_forms_submissions_on_user_and_questionnaire"
    add_reference :decidim_forms_responses, :decidim_submission, index: true, foreign_key: { to_table: :decidim_forms_submissions }
  end
end
