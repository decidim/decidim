# frozen_string_literal: true

require "spec_helper"
module Decidim
  module Surveys
    module Admin
      describe PublishSurvey, type: :command do
        let(:organization) { create(:organization, available_locales: [:en]) }
        let(:survey) { create(:survey, published_at: nil) }
        let(:current_user) { create(:user, :admin, :confirmed, organization:) }
        let(:command) { described_class.new(survey, current_user) }

        describe "call" do
          context "when the survey is not already published" do
            it "publishes the survey" do
              expect(Decidim.traceability).to receive(:perform_action!).with(
                :publish,
                survey,
                current_user,
                visibility: "all"
              ).and_call_original

              expect(command).to broadcast(:ok, survey)
            end
          end

          context "when the survey is already published" do
            before do
              survey.update!(published_at: Time.current)
            end

            it "does not publish the survey" do
              expect { command.call }.not_to(change { survey.reload.published_at })

              expect(command).to broadcast(:invalid)
            end
          end
        end
      end
    end
  end
end
