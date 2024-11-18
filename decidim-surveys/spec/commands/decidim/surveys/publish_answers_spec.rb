# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    describe PublishAnswers do
      describe "call" do
        let(:command) { described_class.new(form) }
        let(:form) do
          double(
            invalid?: invalid,
            question_ids: questions_with_answers_to_publish.pluck(:id),
            questionnaire: create(:questionnaire, questions: questions_with_answers_to_publish + questions_with_answers_not_to_publish),
            current_user:
          )
        end
        let(:current_user) { create(:user, :confirmed, :admin) }
        let(:questions_with_answers_to_publish) { create_list(:questionnaire_question, 3) }
        let(:questions_with_answers_not_to_publish) { create_list(:questionnaire_question, 2) }

        let(:invalid) { false }

        describe "when the form is invalid" do
          let(:invalid) { true }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "does not change the question's survey_answers_published_at field" do
            expect(questions_with_answers_to_publish.pluck(:survey_answers_published_at)).to all(be_nil)
            expect(questions_with_answers_not_to_publish.pluck(:survey_answers_published_at)).to all(be_nil)

            command.call

            questions_with_answers_to_publish.map(&:reload)
            questions_with_answers_not_to_publish.map(&:reload)

            expect(questions_with_answers_to_publish.pluck(:survey_answers_published_at)).to all(be_nil)
            expect(questions_with_answers_not_to_publish.pluck(:survey_answers_published_at)).to all(be_nil)
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "changes the survey_answers_published_at date" do
            expect(questions_with_answers_to_publish.pluck(:survey_answers_published_at)).to all(be_nil)
            expect(questions_with_answers_not_to_publish.pluck(:survey_answers_published_at)).to all(be_nil)

            command.call

            questions_with_answers_to_publish.map(&:reload)
            questions_with_answers_not_to_publish.map(&:reload)

            expect(questions_with_answers_to_publish.pluck(:survey_answers_published_at)).to all(be_within(1.second).of(Time.zone.now))
            expect(questions_with_answers_not_to_publish.pluck(:survey_answers_published_at)).to all(be_nil)
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:publish_answers, form.questionnaire, form.current_user)
              .and_call_original

            expect { command.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
          end
        end
      end
    end
  end
end
