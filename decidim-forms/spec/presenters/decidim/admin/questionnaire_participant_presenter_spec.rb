# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Forms::Admin::QuestionnaireParticipantPresenter, type: :helper do
    subject { described_class.new(participant:) }

    let!(:questionnaire) { create(:questionnaire) }
    let!(:user) { create(:user, organization: questionnaire.questionnaire_for.organization) }
    let!(:questions) do
      [
        create(:questionnaire_question, questionnaire:, position: 1),
        create(:questionnaire_question, :separator, questionnaire:, position: 2),
        create(:questionnaire_question, questionnaire:, position: 3),
        create(:questionnaire_question, :title_and_description, questionnaire:, position: 2)
      ]
    end
    let!(:answers) do
      questions.map { |question| create :answer, user:, questionnaire:, question: }.sort_by { |a| a.question.position }
    end
    let!(:answer) { subject.answers.first.answer }
    let!(:participant) { answers.first }

    describe "ip_hash" do
      context "when participant's ip_hash is present" do
        before do
          answer.update(ip_hash: "some ip")
        end

        it "returns participant ip hash" do
          answers.first.reload
          expect(subject.ip_hash).to eq(answer.ip_hash)
        end
      end

      context "when participant's ip_hash is missing" do
        before do
          answer.update(ip_hash: nil)
        end

        it "returns a hyphen '-'" do
          answers.first.reload
          expect(subject.ip_hash).to eq("-")
        end
      end
    end

    describe "answered_at" do
      it "returns the datetime when the answer was created" do
        answers.first.reload
        expect(subject.answered_at).to eq(answer.created_at)
      end
    end

    describe "registered?" do
      it "returns whether the participant is registered (has an id)" do
        expect(subject.registered?).to eq(answer.decidim_user_id.present?)
      end
    end

    describe "answers" do
      it "returns the participant's answers without the separators and title-and-descriptions" do
        expect(subject.answers.map(&:answer)).to eq([answers.first, answers.last])
        expect(subject.answers.map(&:answer)).not_to include(answers.second)
      end
    end

    describe "commpletion of just one questionnaire" do
      it "returns the participant's completion percentage" do
        expect(subject.completion).to eq(100)
      end
    end

    describe "user answers more than one questionnaire" do
      let!(:component) { create(:component, participatory_space: questionnaire.questionnaire_for, organization: questionnaire.questionnaire_for.organization) }
      let!(:questionnaire2) { create(:questionnaire, questionnaire_for: component) }
      let!(:questions2) { 3.downto(1).map { |n| create :questionnaire_question, questionnaire: questionnaire2, position: n } }
      let!(:answers2) do
        questions2.map { |question| create :answer, user:, questionnaire: questionnaire2, question: }.sort_by { |a| a.question.position }
      end
      let!(:answer) { subject.answers.first.answer }
      let!(:participant2) { answers2.first }

      context "when completion of different questionnaires" do
        it "returns the participant's completion percentage without mixing different questionnaires" do
          expect(subject.completion).to eq(100)
        end
      end
    end
  end
end
