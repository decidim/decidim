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
    let!(:responses) do
      questions.map { |question| create(:response, user:, questionnaire:, question:) }.sort_by { |a| a.question.position }
    end
    let!(:response) { subject.responses.first.response }
    let!(:participant) { responses.first }

    describe "ip_hash" do
      context "when participant's ip_hash is present" do
        before do
          response.update(ip_hash: "some ip")
        end

        it "returns participant ip hash" do
          responses.first.reload
          expect(subject.ip_hash).to eq(response.ip_hash)
        end
      end

      context "when participant's ip_hash is missing" do
        before do
          response.update(ip_hash: nil)
        end

        it "returns a hyphen '-'" do
          responses.first.reload
          expect(subject.ip_hash).to eq("-")
        end
      end
    end

    describe "responded_at" do
      it "returns the datetime when the response was created" do
        responses.first.reload
        expect(subject.responded_at).to eq(response.created_at)
      end
    end

    describe "registered?" do
      it "returns whether the participant is registered (has an id)" do
        expect(subject.registered?).to eq(response.decidim_user_id.present?)
      end
    end

    describe "responses" do
      it "returns the participant's responses without the separators and title-and-descriptions" do
        expect(subject.responses.map(&:response)).to eq([responses.first, responses.last])
        expect(subject.responses.map(&:response)).not_to include(responses.second)
      end
    end

    describe "completion of just one questionnaire" do
      it "returns the participant's completion percentage" do
        expect(subject.completion).to eq(100)
      end
    end

    describe "user responses more than one questionnaire" do
      let!(:component) { create(:component, participatory_space: questionnaire.questionnaire_for, organization: questionnaire.questionnaire_for.organization) }
      let!(:questionnaire2) { create(:questionnaire, questionnaire_for: component) }
      let!(:questions2) { 3.downto(1).map { |n| create(:questionnaire_question, questionnaire: questionnaire2, position: n) } }
      let!(:responses2) do
        questions2.map { |question| create(:response, user:, questionnaire: questionnaire2, question:) }.sort_by { |a| a.question.position }
      end
      let!(:response) { subject.responses.first.response }
      let!(:participant2) { responses2.first }

      context "when completion of different questionnaires" do
        it "returns the participant's completion percentage without mixing different questionnaires" do
          expect(subject.completion).to eq(100)
        end
      end
    end
  end
end
