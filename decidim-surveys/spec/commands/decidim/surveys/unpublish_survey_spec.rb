# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    module Admin
      describe UnpublishSurvey, type: :command do
        let(:organization) { create(:organization, available_locales: [:en]) }
        let(:survey) { create(:survey, published_at: Time.current) }
        let(:current_user) { create(:user, :admin, :confirmed, organization:) }
        let(:command) { described_class.new(survey, current_user) }

        describe "call" do
          context "when the survey is published" do
            it "unpublishes the survey" do
              expect(Decidim.traceability).to receive(:perform_action!).with(
                :unpublish,
                survey,
                current_user
              ).and_call_original

              expect(command).to broadcast(:ok, survey)
            end
          end

          context "when the survey is not published" do
            before do
              survey.update!(published_at: nil)
            end

            it "does not unpublish the survey" do
              expect { command.call }.not_to(change { survey.reload.published_at })

              expect(command).to broadcast(:invalid)
            end
          end
        end
      end
    end
  end
end
