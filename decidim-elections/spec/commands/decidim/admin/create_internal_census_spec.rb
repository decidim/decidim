# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    module Admin
      describe CreateInternalCensus do
        subject { command.call }

        let(:organization) { create(:organization) }
        let(:component) { create(:elections_component, organization:) }
        let(:election) { create(:election, component:, internal_census: false, verification_types: ["id_documents"]) }
        let(:current_user) { create(:user, :admin, :confirmed, organization:) }

        let(:command) { described_class.new(form, election) }

        let(:form) do
          CensusPermissionsForm
            .from_params(form_params)
            .with_context(
              current_user:,
              current_component: component,
              current_organization: organization
            )
        end

        let(:form_params) do
          {
            verification_types: ["id_documents"]
          }
        end

        context "when the form is invalid" do
          before do
            allow(form).to receive(:valid?).and_return(false)
          end

          it "broadcasts invalid" do
            expect { subject }.to broadcast(:invalid)
          end
        end

        context "when the form is valid but no users match" do
          before do
            allow(form).to receive(:valid?).and_return(true)
            allow(form).to receive(:data).and_return([])
          end

          it "broadcasts ok and does not insert voters" do
            expect(Decidim::Elections::Voter).not_to receive(:insert_all)
            expect { subject }.to broadcast(:ok)
            expect(election.reload).to be_internal_census
            expect(election.verification_types).to eq(["id_documents"])
          end
        end

        context "when the form is valid and verified users exist" do
          let!(:user1) { create(:user, :confirmed, organization:) }
          let!(:user2) { create(:user, :confirmed, organization:) }

          before do
            allow(organization).to receive(:available_authorizations).and_return(["id_documents"])

            create(:authorization, name: "id_documents", granted_at: 1.day.ago, user: user1)
            create(:authorization, name: "id_documents", granted_at: 1.day.ago, user: user2)
          end

          it "inserts voters and broadcasts ok" do
            expect(Decidim::Elections::Voter).to receive(:insert_all).with(
              election,
              array_including(
                [user1.email, a_string_matching(/#{user1.email}-#{election.id}-/)],
                [user2.email, a_string_matching(/#{user2.email}-#{election.id}-/)]
              )
            )

            expect { subject }.to broadcast(:ok)
            expect(election.reload).to be_internal_census
            expect(election.reload.verification_types).to eq(["id_documents"])
          end
        end
      end
    end
  end
end
