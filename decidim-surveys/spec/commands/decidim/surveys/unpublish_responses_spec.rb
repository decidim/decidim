# frozen_string_literal: true

require "spec_helper"

module Decidim::Surveys
  describe UnpublishResponses do
    describe "call" do
      let(:command) { described_class.new(question.id, current_user) }
      let(:question) { create(:questionnaire_question, survey_responses_published_at: Time.current) }
      let(:current_user) { create(:user, :confirmed, :admin) }

      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "changes the survey_responses_published_at date" do
        expect { command.call }.to(change { question.reload.survey_responses_published_at })
        expect(question.survey_responses_published_at).to be_nil
      end

      it "traces the action", versioning: true do
        expect(Decidim::ActionLogger)
          .to(
            receive(:log)
              .with(
                "unpublish_responses",
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
    end
  end
end
