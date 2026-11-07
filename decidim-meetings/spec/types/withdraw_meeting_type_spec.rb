# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe WithdrawMeetingType, type: :graphql do
      include_context "with a graphql class mutation"

      let(:root_klass) { MeetingMutationType }
      let(:organization) { create(:organization, available_locales: [:en]) }
      let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
      let(:user) { create(:user, :confirmed, organization:) }
      let(:component) { create(:meeting_component, participatory_space: participatory_process) }
      let!(:model) { create(:meeting, :published, component:, author: user) }
      let(:current_user) { user }

      let(:query) do
        <<~GRAPHQL
          mutation() {
            withdraw(input: {}) {
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

        it "raises a Decidim::Api::Errors::MutationNotAuthorizedError exception" do
          expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
        end
      end

      context "when meeting is already withdrawn" do
        let!(:model) { create(:meeting, :published, :withdrawn, component:, author: user) }

        it "does not withdraw the meeting and returns an error" do
          expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
          expect(model.reload).to be_withdrawn
          expect(model.withdrawn_at).to be_present
        end
      end
    end
  end
end
