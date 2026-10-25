# frozen_string_literal: true

namespace :decidim_forms do
  namespace :upgrade do
    desc "Groups the questionnaire responses left without a submission into submissions"
    task fix_orphan_responses: :environment do
      orphans = Decidim::Forms::Response.where(decidim_submission_id: nil, decidim_questionnaire_id: Decidim::Forms::Questionnaire.select(:id))
      puts "#{orphans.count} responses without a submission found"

      orphans.where(session_token: "").where.not(decidim_user_id: nil).distinct.pluck(:decidim_user_id).each do |user_id|
        token = Digest::SHA256.hexdigest("#{user_id}-#{Rails.application.secret_key_base}")
        orphans.where(session_token: "", decidim_user_id: user_id).update_all(session_token: token) # rubocop:disable Rails/SkipsModelValidations
      end

      orphans.distinct.pluck(:decidim_questionnaire_id, :session_token).each do |questionnaire_id, session_token|
        rows = orphans.where(decidim_questionnaire_id: questionnaire_id, session_token:)

        Decidim::Forms::Submission.transaction do
          submission = Decidim::Forms::Submission.find_or_create_by!(decidim_questionnaire_id: questionnaire_id, session_token:) do |new_submission|
            new_submission.decidim_user_id = rows.maximum(:decidim_user_id)
            new_submission.ip_hash = rows.maximum(:ip_hash)
            new_submission.created_at = rows.minimum(:created_at)
            new_submission.updated_at = rows.maximum(:updated_at)
          end
          rows.update_all(decidim_submission_id: submission.id) # rubocop:disable Rails/SkipsModelValidations
        end
      end

      unlinked_responses = orphans.count
      raise "#{unlinked_responses} responses with an existing questionnaire remain unlinked" if unlinked_responses.positive?

      puts "#{Decidim::Forms::Response.where(decidim_submission_id: nil).count} responses without an existing questionnaire were left unlinked"
    end
  end
end
