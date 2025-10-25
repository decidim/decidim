# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/mutation_context"

module Decidim
  module Meetings
    describe WithdrawMeetingType, type: :graphql do
      include_context "with a graphql class mutation"

      let(:root_klass) { MeetingMutationType }
      let(:organization) { create(:organization) }
      let(:participatory_process) { create(:participatory_process, organization:) }
      let(:component) { create(:meeting_component, participatory_space: participatory_process) }
      let(:user) { create(:user, :confirmed, organization:) }
      let!(:model) { create(:meeting, component:, author: user) }
      
      let(:variables) do
        {
          input: {
            attributes: {}
          }
        }
      end
      
      let(:query) do
        <<~GRAPHQL
          mutation($input: WithdrawMeetingInput!) {
            withdraw(input: $input) {
              id
              title { translation(locale: "en") }
              withdrawn
              withdrawnAt
            }
          }
        GRAPHQL
      end

      context "when user is the author of the meeting" do
        it "withdraws the meeting" do
          expect(response["withdraw"]).to be_present
          expect(response["withdraw"]["id"]).to eq(model.id.to_s)
          expect(response["withdraw"]["withdrawn"]).to be(true)
          expect(response["withdraw"]["withdrawnAt"]).to be_present
          expect(model.reload).to be_withdrawn
        end
      end

      context "when user is not the author of the meeting" do
        let(:other_user) { create(:user, :confirmed, organization:) }
        let(:current_user) { other_user }

        it "returns nil" do
          expect(response["withdraw"]).to be_nil
        end
      end

      context "with api_user as author" do
        let(:api_user) { create(:user, :confirmed, organization:) }
        let!(:model) { create(:meeting, component:, author: api_user) }
        let(:current_user) { api_user }

        it "withdraws the meeting" do
          expect(response["withdraw"]).to be_present
          expect(response["withdraw"]["id"]).to eq(model.id.to_s)
          expect(response["withdraw"]["withdrawn"]).to be(true)
          expect(model.reload).to be_withdrawn
        end
      end
    end
  end
end
