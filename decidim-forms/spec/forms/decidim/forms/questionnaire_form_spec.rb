# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe QuestionnaireForm do
      subject do
        described_class.from_model(questionnaire).with_context(context)
      end

      let!(:questionnaire) { create(:questionnaire) }
      let!(:question) { create(:questionnaire_question, questionnaire: questionnaire) }
      let(:current_user) { create(:user) }
      let(:session_token) { "some-token" }
      let(:in_full_form_mode) { false }
      let(:context) do
        {
          in_full_form_mode: in_full_form_mode,
          session_token: session_token
        }
      end

      it "builds empty answers for each question" do
        expect(subject.responses.length).to eq(1)
      end

      context "when not in full form mode" do
        context "when tos_agreement is not accepted" do
          it { is_expected.to be_valid }
        end
      end

      context "when in full form mode" do
        let(:in_full_form_mode) { true }

        context "when tos_agreement is not accepted" do
          it { is_expected.not_to be_valid }
        end
      end

      context "when tos_agreement is accepted" do
        before do
          subject.tos_agreement = true
        end

        context "and no token is present" do
          let(:session_token) { nil }

          it { is_expected.not_to be_valid }
        end

        context "and token is present" do
          let(:ip_hash) { nil }

          it { is_expected.to be_valid }
        end
      end
    end
  end
end
