# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe Submission do
      subject { submission }

      let(:questionnaire) { create(:questionnaire) }
      let(:submission) { create(:submission, questionnaire:) }

      it { is_expected.to be_valid }

      it "rejects a duplicate session token in the same questionnaire" do
        expect { create(:submission, questionnaire:, session_token: submission.session_token) }.to raise_error(ActiveRecord::RecordNotUnique)
      end

      it "allows the same session token in another questionnaire" do
        other = create(:submission, session_token: submission.session_token)
        expect(other).to be_persisted
      end

      it "destroys its responses" do
        response = create(:response, questionnaire:, submission:)
        submission.destroy!
        expect(Response.where(id: response.id)).not_to exist
      end

      describe "counter cache" do
        it "increments the questionnaire submissions_count when a submission is created" do
          expect { create(:submission, questionnaire:) }.to change { questionnaire.reload.submissions_count }.by(1)
        end

        it "decrements the questionnaire submissions_count when a submission is destroyed" do
          submission

          expect { submission.destroy! }.to change { questionnaire.reload.submissions_count }.by(-1)
        end

        it "updates both questionnaires submissions_count when a submission is reassigned to another questionnaire" do
          other_questionnaire = create(:questionnaire)

          submission.update!(questionnaire: other_questionnaire)

          expect(questionnaire.reload.submissions_count).to eq(0)
          expect(other_questionnaire.reload.submissions_count).to eq(1)
        end

        context "with concurrent creations" do
          it_behaves_like "a concurrency safe counter cache" do
            let(:counter_parent) { questionnaire }
            let(:counter_column) { :submissions_count }
            let(:counter_children) do
              users = create_list(:user, 5, organization: questionnaire.questionnaire_for.organization)

              users.map { |user| ->(parent) { create(:submission, questionnaire: parent, user:) } }
            end
          end
        end
      end

      context "when anonymous" do
        let(:submission) { create(:submission, questionnaire:, user: nil) }

        it { is_expected.to be_valid }
      end
    end
  end
end
