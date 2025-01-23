# frozen_string_literal: true

require "spec_helper"

module Decidim::Surveys
  describe PublishAnswers do
    describe "call" do
      let(:command) { described_class.new(question.id, current_user) }
      let(:question) { create(:questionnaire_question) }
      let(:current_user) { create(:user, :confirmed, :admin) }

      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "changes the survey_answers_published_at date" do
        expect { command.call }.to(change { question.reload.survey_answers_published_at })
        expect(question.survey_answers_published_at).to(be_within(1.second).of(Time.zone.now))
      end

      it "traces the action", versioning: true do
        expect(Decidim::ActionLogger)
          .to(
            receive(:log)
              .with(
                "publish_answers",
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
