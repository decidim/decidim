# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe Questionnaire do
      subject { questionnaire }

      let!(:questionable) { create(:dummy_resource) }
      let(:questionnaire) { create(:questionnaire, questionnaire_for: questionable) }

      it { is_expected.to be_valid }

      it "has an association of questions" do
        subject.questions << create(:questionnaire_question)
        subject.questions << create(:questionnaire_question)
        expect(subject.questions.count).to eq(2)
      end

      it "has an association of answers" do
        create(:answer, questionnaire: subject, user: create(:user, organization: questionable.organization))
        create(:answer, questionnaire: subject, user: create(:user, organization: questionable.organization))
        expect(subject.reload.answers.count).to eq(2)
      end

      context "without a questionable" do
        let(:questionnaire) { build(:questionnaire, questionnaire_for: nil) }

        it { is_expected.not_to be_valid }
      end

      it "has an associated questionable" do
        expect(questionnaire.questionnaire_for).to eq(questionable)
      end

      describe "#count_participants" do
        it "returns the unique participants number" do
          user1 = create(:user, organization: questionable.organization)
          create(:answer, questionnaire: subject, user: user1)
          create(:answer, questionnaire: subject, user: user1)
          create(:answer, questionnaire: subject, user: create(:user, organization: questionable.organization))

          expect(subject.reload.count_participants).to eq(2)
        end
      end

      describe "#questions_editable?" do
        it "returns false when questionnaire has already answers" do
          create(:answer, questionnaire:)
          expect(subject.reload).not_to be_questions_editable
        end
      end

      describe "#answered_by?" do
        let!(:user) { create(:user, organization: questionnaire.questionnaire_for.component.participatory_space.organization) }
        let!(:question) { create(:questionnaire_question, questionnaire:) }

        it "returns false if the given user has not answered the questionnaire" do
          expect(questionnaire).not_to be_answered_by(user)
        end

        it "returns true if the given user has answered the questionnaire" do
          create(:answer, questionnaire:, question:, user:)
          expect(questionnaire).to be_answered_by(user)
        end
      end

      describe "#pristine?" do
        context "when created_at and updated_at are equal" do
          let(:questionnaire) { create(:questionnaire) }

          context "when questionnaire has no questions" do
            it "returns true" do
              expect(questionnaire.pristine?).to be(true)
            end
          end

          context "when questionnaire has questions" do
            let!(:question) { create(:questionnaire_question, questionnaire:) }

            it "returns false" do
              expect(questionnaire.pristine?).to be(false)
            end
          end
        end

        context "when created_at and updated_at are different" do
          let(:questionnaire) { create(:questionnaire, created_at: 1.day.ago) }

          it "returns false" do
            expect(questionnaire.pristine?).to be(false)
          end
        end
      end
    end
  end
end
