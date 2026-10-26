# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe Response do
      subject { response }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, organization:) }
      let(:participatory_process) { create(:participatory_process, organization:) }
      let(:questionnaire) { create(:questionnaire, questionnaire_for: participatory_process) }
      let(:question) { create(:questionnaire_question, questionnaire:) }
      let(:response) { create(:response, questionnaire:, question:, user:) }

      it { is_expected.to be_valid }

      it "has an association of questionnaire" do
        expect(subject.questionnaire).to eq(questionnaire)
      end

      it "has an association of question" do
        expect(subject.question).to eq(question)
      end

      it "has an association of user" do
        expect(subject.user).to eq(user)
      end

      describe "counter cache" do
        it "increments the questionnaire responses_count when a response is created" do
          expect do
            create(:response, questionnaire:, question:, user:)
          end.to change { questionnaire.reload.responses_count }.by(1)
        end

        it "decrements the questionnaire responses_count when a response is destroyed" do
          response

          expect do
            response.destroy!
          end.to change { questionnaire.reload.responses_count }.by(-1)
        end

        it "updates both questionnaires responses_count when a response is reassigned to another questionnaire" do
          other_questionnaire = create(:questionnaire, questionnaire_for: participatory_process)
          other_question = create(:questionnaire_question, questionnaire: other_questionnaire)

          response.update!(questionnaire: other_questionnaire, question: other_question)

          expect(questionnaire.reload.responses_count).to eq(0)
          expect(other_questionnaire.reload.responses_count).to eq(1)
        end

        context "with concurrent creations" do
          it_behaves_like "a concurrency safe counter cache" do
            let(:counter_parent) { questionnaire }
            let(:counter_column) { :responses_count }
            let(:counter_children) do
              item = question
              users = create_list(:user, 5, organization:)

              users.map do |respondent|
                ->(parent) { create(:response, questionnaire: parent, question: item, user: respondent) }
              end
            end
          end
        end
      end

      context "when the user does not belong to the same organization" do
        it "is not valid" do
          subject.user = create(:user)
          expect(subject).not_to be_valid
        end
      end

      context "when question does not belong to the questionnaire" do
        it "is not valid" do
          subject.question = create(:questionnaire_question)
          expect(subject).not_to be_valid
        end
      end
    end
  end
end
