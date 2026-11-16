# frozen_string_literal: true

require "spec_helper"

module Decidim::Surveys
  describe PublishResponses do
    describe "call" do
      let(:command) { described_class.new(question.questionnaire, question.id, current_user) }
      let(:question) { create(:questionnaire_question) }
      let(:current_user) { create(:user, :confirmed, :admin) }

      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "changes the survey_responses_published_at date" do
        expect { command.call }.to(change { question.reload.survey_responses_published_at })
        expect(question.survey_responses_published_at).to(be_within(1.second).of(Time.zone.now))
      end

      it "traces the action", versioning: true do
        expect(Decidim::ActionLogger)
          .to(
            receive(:log)
              .with(
                "publish_responses",
                current_user,
                question,
                nil,
                resource: { title: translated_attribute(question.body) },
                participatory_space: { title: question.questionnaire.questionnaire_for.title }
              )
              .and_call_original
          )

        expect { command.call }.to change(Decidim::ActionLog, :count)
      end

      context "when the question belongs to another questionnaire" do
        let(:other_question) { create(:questionnaire_question) }
        let(:command) { described_class.new(question.questionnaire, other_question.id, current_user) }

        it "does not publish the foreign question" do
          expect { command.call }.to broadcast(:invalid)
          expect(other_question.reload.survey_responses_published_at).to be_nil
        end
      end
    end
  end
end
