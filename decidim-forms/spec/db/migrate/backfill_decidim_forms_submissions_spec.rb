# frozen_string_literal: true

require "spec_helper"

require "./db/migrate/20261007100100_backfill_decidim_forms_submissions"

describe BackfillDecidimFormsSubmissions do
  let(:migrator) { described_class.new.tap { |migration| migration.verbose = false } }

  let(:questionnaire) { create(:questionnaire, :with_questions) }
  let(:questions) { questionnaire.questions }
  let(:user) { create(:user, organization: questionnaire.questionnaire_for.organization) }
  let(:ip_hash) { "ip-1" }
  let(:other_questionnaire) { create(:questionnaire, :with_questions) }

  # Rows as the old code stored them: no submission, one participant = one session token
  let(:legacy_rows) do
    [
      # a logged-in participant who responded to two questions and edited the second one a day later
      { decidim_question_id: questions[0].id, decidim_user_id: user.id, session_token: "user-token", ip_hash:, created_at: 2.days.ago, updated_at: 2.days.ago },
      { decidim_question_id: questions[1].id, decidim_user_id: user.id, session_token: "user-token", ip_hash:, created_at: 2.days.ago, updated_at: 1.day.ago },
      # an anonymous participant
      { decidim_question_id: questions[0].id, decidim_user_id: nil, session_token: "anon-token", ip_hash: "ip-2", created_at: 1.day.ago, updated_at: 1.day.ago },
      # two rows for one question under an empty token: the migration links both to one submission, deletes nothing and only counts the group
      { decidim_question_id: questions[0].id, decidim_user_id: nil, session_token: "", ip_hash: nil, created_at: 3.days.ago, updated_at: 3.days.ago },
      { decidim_question_id: questions[0].id, decidim_user_id: nil, session_token: "", ip_hash: nil, created_at: 3.days.ago, updated_at: 3.days.ago }
    ].map { |row| row.merge(decidim_questionnaire_id: questionnaire.id, body: "legacy") }
  end

  def legacy_row(**attributes)
    { decidim_questionnaire_id: questionnaire.id, decidim_user_id: nil, session_token: "user-token", ip_hash: nil, body: "legacy", created_at: 1.day.ago, updated_at: 1.day.ago }.merge(attributes)
  end

  before { Decidim::Forms::Response.insert_all(legacy_rows) } # rubocop:disable Rails/SkipsModelValidations

  describe "#up" do
    it "groups legacy rows into submissions by questionnaire and session token" do
      migrator.migrate(:up)

      expect(questionnaire.submissions.count).to eq(3)
      submission = questionnaire.submissions.find_by(session_token: "user-token")
      expect(submission.user).to eq(user)
      expect(submission.ip_hash).to eq(ip_hash)
      expect(submission.created_at).to be_within(1.second).of(2.days.ago)
      expect(submission.updated_at).to be_within(1.second).of(1.day.ago)
      expect(submission.responses.count).to eq(2)
      expect(questionnaire.submissions.find_by(session_token: "anon-token").user).to be_nil
      expect(Decidim::Forms::Response.where(decidim_submission_id: nil)).not_to exist
    end

    it "keeps every row, including duplicates under an empty token" do
      allow(migrator).to receive(:say)

      expect { migrator.migrate(:up) }.not_to change(Decidim::Forms::Response, :count)
      expect(questionnaire.submissions.find_by(session_token: "").responses.count).to eq(2)
      expect(migrator).to have_received(:say).with(/\A1 response groups/)
    end

    it "keeps the same session token in different questionnaires apart" do
      Decidim::Forms::Response.insert_all([legacy_row(decidim_questionnaire_id: other_questionnaire.id, decidim_question_id: other_questionnaire.questions.first.id)]) # rubocop:disable Rails/SkipsModelValidations

      migrator.migrate(:up)

      expect(Decidim::Forms::Submission.where(session_token: "user-token").count).to eq(2)
    end

    it "links rows added after a previous run to the existing submission" do
      migrator.migrate(:up)
      Decidim::Forms::Response.insert_all([legacy_row(decidim_question_id: questions[2].id, decidim_user_id: user.id)]) # rubocop:disable Rails/SkipsModelValidations

      expect { migrator.migrate(:up) }.not_to change(Decidim::Forms::Submission, :count)
      expect(questionnaire.submissions.find_by(session_token: "user-token").responses.count).to eq(3)
    end

    it "leaves rows without an existing questionnaire unlinked" do
      allow(migrator).to receive(:say)
      orphan_rows = [
        legacy_row(decidim_questionnaire_id: questionnaire.id + 1000, decidim_question_id: questions[0].id, session_token: "orphan-token"),
        legacy_row(decidim_questionnaire_id: nil, decidim_question_id: questions[0].id, session_token: "nil-token")
      ]
      Decidim::Forms::Response.insert_all(orphan_rows) # rubocop:disable Rails/SkipsModelValidations

      migrator.migrate(:up)

      expect(Decidim::Forms::Response.where(session_token: %w(orphan-token nil-token)).pluck(:decidim_submission_id)).to eq([nil, nil])
      expect(Decidim::Forms::Submission.where(session_token: %w(orphan-token nil-token))).not_to exist
      expect(migrator).to have_received(:say).with(/\A2 responses without an existing questionnaire/)
    end
  end

  describe "#down" do
    it "removes the submissions and unlinks the responses" do
      migrator.migrate(:up)
      migrator.migrate(:down)
      expect(Decidim::Forms::Submission.count).to eq(0)
      expect(Decidim::Forms::Response.where.not(decidim_submission_id: nil)).not_to exist
    end
  end
end
