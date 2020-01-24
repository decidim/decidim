# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Forms::Admin::QuestionnaireParticipantPresenter, type: :helper do
    subject { described_class.new(questionnaire: questionnaire, session_token: session_token) }

    let!(:questionnaire) { create(:questionnaire) }
    let!(:user) { create(:user, organization: questionnaire.questionnaire_for.organization) }
    let!(:questions) { 3.downto(1).map { |n| create :questionnaire_question, questionnaire: questionnaire, position: n } }
    let!(:answers) { questions.map { |question| create :answer, user: user, questionnaire: questionnaire, question: question } }
    let!(:answer) { subject.answers.first }
    let!(:session_token) { answers.first.session_token }

    describe "ip_hash" do
      context "when participant's ip_hash is present" do
        before do
          answer.update(ip_hash: "some ip")
        end

        it "returns participant ip hash" do
          expect(subject.ip_hash).to eq(answer.ip_hash)
        end
      end

      context "when participant's ip_hash is missing" do
        before do
          answer.update(ip_hash: nil)
        end

        it "returns a hyphen '-'" do
          expect(subject.ip_hash).to eq("-")
        end
      end
    end

    describe "answered_at" do
      it "returns the datetime when the answer was created" do
        expect(subject.answered_at).to eq(answer.created_at)
      end
    end

    describe "registered?" do
      it "returns whether the participant is registered (has an id)" do
        expect(subject.registered?).to eq(answer.decidim_user_id.present?)
      end
    end

    describe "answers" do
      it "returns the participant's answers" do
        expect(subject.answers).to eq(answers)
      end
    end

    describe "commpletion" do
      it "returns the participant's completion percentage" do
        expect(subject.completion).to eq(100)
      end
    end
  end
end
