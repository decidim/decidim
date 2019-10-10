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
      let(:ip_hash) { "some-hash" }
      let(:context) do
        {
          current_user: current_user,
          ip_hash: ip_hash
        }
      end

      it "builds empty answers for each question" do
        expect(subject.answers.length).to eq(1)
      end

      context "when tos_agreement is not accepted" do
        it { is_expected.not_to be_valid }
      end

      context "when tos_agreement is accepted" do
        before do
          subject.tos_agreement = true
        end

        context "and no user, no ip is present" do
          let(:current_user) { nil }
          let(:ip_hash) { nil }

          it { is_expected.not_to be_valid }
        end

        context "and user is present but no ip" do
          let(:ip_hash) { nil }

          it { is_expected.to be_valid }
        end

        context "and no user is present but ip is" do
          let(:current_user) { nil }

          it { is_expected.to be_valid }
        end
      end
    end
  end
end
