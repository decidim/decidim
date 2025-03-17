# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe CreateResponse do
      let(:current_organization) { create(:organization) }
      let(:current_user) { create(:user, organization: meeting_component.organization) }
      let(:meeting_component) { create(:meeting_component) }
      let(:meeting) { create(:meeting, component: meeting_component) }
      let(:poll) { create(:poll, meeting:) }
      let(:questionnaire) { create(:meetings_poll_questionnaire, questionnaire_for: poll) }
      let(:question) { create(:meetings_poll_question, questionnaire:) }
      let(:response_options) { create_list(:meetings_poll_response_option, 5, question:) }
      let(:response_option_ids) { response_options.pluck(:id).map(&:to_s) }
      let(:form_params) do
        {
          "response" => {
            "choices" => [
              { "response_option_id" => response_option_ids[0], "body" => "My" },
              { "response_option_id" => response_option_ids[1], "body" => "second" },
              { "response_option_id" => response_option_ids[2], "body" => "response" }
            ],
            "question_id" => question.id
          }
        }
      end
      let(:form) do
        ResponseForm.from_params(
          form_params
        ).with_context(
          current_organization:,
          current_user:
        )
      end
      let(:command) { described_class.new(form, questionnaire) }

      describe "when the form is invalid" do
        before do
          allow(form).to receive(:invalid?).and_return(true)
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "does not create questionnaire responses" do
          expect do
            command.call
          end.not_to change(Response, :count)
        end
      end

      describe "when the form is valid" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "creates a questionnaire response for each question responded" do
          expect do
            command.call
          end.to change(Response, :count).by(1)
          expect(Response.all.map(&:questionnaire)).to eq([questionnaire])
        end

        it "creates responses with the correct information" do
          command.call

          expect(Response.first.choices.map(&:body)).to eq(%w(My second response))
        end
      end
    end
  end
end
