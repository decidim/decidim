# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    module Admin
      describe UpdateQuestionStatus do
        let(:current_organization) { create(:organization) }
        let(:current_user) { create :user, organization: meeting_component.organization }
        let(:meeting_component) { create :meeting_component }
        let(:meeting) { create :meeting, component: meeting_component }
        let(:poll) { create :poll, meeting: }
        let(:questionnaire) { create :meetings_poll_questionnaire, questionnaire_for: poll }
        let(:question) { create :meetings_poll_question, questionnaire: }
        let(:command) { described_class.new(question, current_user) }

        context "with a persisted poll and questionnaire" do
          describe "when the status is unpublished" do
            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end

            it "updates the question status to published" do
              command.call
              question.reload
              expect(question).to be_published
            end
          end

          describe "when the status is published" do
            let(:question) { create :meetings_poll_question, :published, questionnaire: }

            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end

            it "updates the question status to closed" do
              command.call
              question.reload
              expect(question).to be_closed
            end
          end

          describe "when the status is closed" do
            let(:question) { create :meetings_poll_question, :closed, questionnaire: }

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end
          end
        end
      end
    end
  end
end
