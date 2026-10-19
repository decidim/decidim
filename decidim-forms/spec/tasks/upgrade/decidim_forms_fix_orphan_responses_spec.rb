# frozen_string_literal: true

require "spec_helper"

describe "rake decidim_forms:upgrade:fix_orphan_responses", type: :task do
  let(:questionnaire) { create(:questionnaire, :with_questions) }
  let(:questions) { questionnaire.questions }
  let(:user) { create(:user, organization: questionnaire.questionnaire_for.organization) }
  let!(:submission) { create(:submission, questionnaire:, user:, session_token: "known-token") }

  let(:orphan_rows) do
    [
      { decidim_question_id: questions[0].id, session_token: "known-token", decidim_user_id: user.id, ip_hash: "ip-1" },
      { decidim_question_id: questions[0].id, session_token: "new-token", decidim_user_id: nil, ip_hash: "ip-2" },
      { decidim_question_id: questions[1].id, session_token: "new-token", decidim_user_id: nil, ip_hash: "ip-2" }
    ].map { |row| row.merge(decidim_questionnaire_id: questionnaire.id, body: "legacy", created_at: 1.day.ago, updated_at: 1.day.ago) }
  end

  before { Decidim::Forms::Response.insert_all(orphan_rows) } # rubocop:disable Rails/SkipsModelValidations

  it "links the orphan responses to their existing or new submission" do
    task.execute

    expect(submission.responses.count).to eq(1)
    new_submission = questionnaire.submissions.find_by(session_token: "new-token")
    expect(new_submission.user).to be_nil
    expect(new_submission.ip_hash).to eq("ip-2")
    expect(new_submission.responses.count).to eq(2)
    expect(Decidim::Forms::Response.where(decidim_submission_id: nil)).not_to exist
  end

  it "changes nothing on a second run" do
    task.execute

    expect { task.execute }.not_to change(Decidim::Forms::Submission, :count)
  end
end
