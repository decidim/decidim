# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe CloseMeetingType, type: :graphql do
      include_context "with a graphql class mutation"

      let(:root_klass) { MeetingMutationType }
      let(:organization) { current_organization }
      let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
      let(:meetings_component) { create(:meeting_component, participatory_space: participatory_process) }
      let(:author) { current_user }
      let!(:model) { create(:meeting, :published, component: meetings_component, author:, end_time:, start_time:) }
      let(:attendees_count) { 10 }
      let(:closing_report) { "My meeting closing report" }
      let(:component) { model.component }
      let(:proposal_ids) { [] }
      let(:locale) { "en" }
      let(:end_time) { 1.day.ago }
      let(:start_time) { 2.days.ago }

      let(:variables) do
        {
          input: {
            locale:,
            attributes: {
              closingReport: closing_report,
              attendeesCount: attendees_count,
              proposalIds: proposal_ids
            }
          }
        }
      end

      let(:query) do
        <<~GRAPHQL
          mutation($input: CloseMeetingInput!) {
            close(input: $input) {
              id
              closed
              attendeesCount
              closingReport { translation(locale: "en") }
              closedAt
            }
          }
        GRAPHQL
      end

      shared_examples "manage meeting mutation examples" do
        context "when meeting is in the future" do
          let(:end_time) { 1.day.from_now }

          it "raises a Decidim::Api::Errors::MutationNotAuthorizedError" do
            expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
          end
        end

        context "when meeting can be closed" do
          it "closes the meeting" do
            close = response["close"]
            expect(close).to be_present
            expect(close).to include(
              {
                "id" => model.id.to_s,
                "closed" => true,
                "attendeesCount" => attendees_count,
                "closingReport" => {
                  "translation" => closing_report
                },
                "closedAt" => model.reload.closed_at.to_time.iso8601
              }
            )
            expect(model.reload).to be_closed
          end

          context "with linked proposals" do
            let!(:proposals_component) { create(:proposal_component, participatory_space: participatory_process) }
            let!(:proposal1) { create(:proposal, component: proposals_component) }
            let!(:proposal2) { create(:proposal, component: proposals_component) }
            let!(:proposal_ids) { [proposal1.id, proposal2.id].map(&:to_s) }

            it "closes the meeting and links proposals" do
              close = response["close"]
              expect(close).to be_present

              expect(model.reload).to be_closed

              # Verify proposals are linked
              expect(model.reload.linked_resources(:proposals, "proposals_from_meeting").pluck(:id)).to match_array(proposal_ids.collect(&:to_i))
            end
          end
        end
      end

      context "with admin user" do
        it_behaves_like "manage meeting mutation examples" do
          let!(:user_type) { :admin }
        end
      end

      context "with normal user" do
        it_behaves_like "manage meeting mutation examples"
      end

      context "with api_user" do
        it_behaves_like "manage meeting mutation examples" do
          let!(:user_type) { :api_user }
        end
      end

      context "when validating" do
        context "with issues on attendees_count" do
          context "when the value is not sent" do
            let(:variables) do
              {
                input: {
                  locale:,
                  attributes: {
                    closingReport: closing_report,
                    proposalIds: proposal_ids
                  }
                }
              }
            end

            it "raises an error" do
              expect { response }.to raise_error(::GraphQL::ExecutionError, /Expected value to not be null/)
            end
          end

          context "when the value is not an integer" do
            let(:attendees_count) { "not_an_integer" }

            it "raises an error" do
              expect { response }.to raise_error(::GraphQL::ExecutionError, /Could not coerce value "not_an_integer" to Int/)
            end
          end

          context "when the value is less than 0" do
            let(:attendees_count) { -1 }

            it "raises an error" do
              expect { response }.to raise_error(Api::Errors::AttributeValidationError, /must be greater than or equal to 0/)
            end
          end

          context "when the value is larger than 1000" do
            let(:attendees_count) { 1000 }

            it "raises an error" do
              expect { response }.to raise_error(Api::Errors::AttributeValidationError, /must be less than or equal to 999/)
            end
          end
        end

        context "with an invalid locale" do
          let(:locale) { "tlh" }

          it "raises an error" do
            expect { response }.to raise_error(Api::Errors::InvalidLocaleError, /Invalid locale provided/)
          end
        end

        context "when having an invalid closing_report" do
          context "when is missing" do
            let(:closing_report) { "" }

            it "raises an error" do
              expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /cannot be blank/)
            end
          end
        end
      end

      context "when anonymous user" do
        let(:current_user) { nil }
        let(:author) { create(:user, :confirmed, organization: current_organization) }

        it "raises a Decidim::Api::Errors::MutationNotAuthorizedError" do
          expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
        end
      end

      context "when meeting is not published" do
        let!(:model) { create(:meeting, component: meetings_component, author:, end_time:, start_time:) }

        it "raises a Decidim::Api::Errors::MutationNotAuthorizedError" do
          expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
        end
      end

      context "when meeting is closed" do
        let!(:model) { create(:meeting, :published, :closed_with_minutes, component: meetings_component, author:) }

        it "raises a Decidim::Api::Errors::MutationNotAuthorizedError" do
          expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
        end
      end

      context "when meeting is withdrawn" do
        let!(:model) { create(:meeting, :withdrawn, :closed_with_minutes, component: meetings_component, author:) }

        it "raises a Decidim::Api::Errors::MutationNotAuthorizedError" do
          expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
        end
      end
    end
  end
end
