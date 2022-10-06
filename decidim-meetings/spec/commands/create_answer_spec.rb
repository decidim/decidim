# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe CreateAnswer do
      let(:current_organization) { create(:organization) }
      let(:current_user) { create :user, organization: meeting_component.organization }
      let(:meeting_component) { create :meeting_component }
      let(:meeting) { create :meeting, component: meeting_component }
      let(:poll) { create :poll, meeting: }
      let(:questionnaire) { create :meetings_poll_questionnaire, questionnaire_for: poll }
      let(:question) { create :meetings_poll_question, questionnaire: }
      let(:answer_options) { create_list(:meetings_poll_answer_option, 5, question:) }
      let(:answer_option_ids) { answer_options.pluck(:id).map(&:to_s) }
      let(:form_params) do
        {
          "answer" => {
            "choices" => [
              { "answer_option_id" => answer_option_ids[0], "body" => "My" },
              { "answer_option_id" => answer_option_ids[1], "body" => "second" },
              { "answer_option_id" => answer_option_ids[2], "body" => "answer" }
            ],
            "question_id" => question.id
          }
        }
      end
      let(:form) do
        AnswerForm.from_params(
          form_params
        ).with_context(
          current_organization:
        )
      end
      let(:command) { described_class.new(form, current_user, questionnaire) }

      describe "when the form is invalid" do
        before do
          allow(form).to receive(:invalid?).and_return(true)
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "doesn't create questionnaire answers" do
          expect do
            command.call
          end.not_to change(Answer, :count)
        end
      end

      describe "when the form is valid" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "creates a questionnaire answer for each question answered" do
          expect do
            command.call
          end.to change(Answer, :count).by(1)
          expect(Answer.all.map(&:questionnaire)).to eq([questionnaire])
        end

        it "creates answers with the correct information" do
          command.call

          expect(Answer.first.choices.map(&:body)).to eq(%w(My second answer))
        end
      end
    end
  end
end
