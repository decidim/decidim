# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe AcceptAccessToCollaborativeDraftForm do
        subject { form }

        let(:organization) { create(:organization) }
        let(:collaborative_draft) { create(:collaborative_draft, :open) }
        let(:state) { collaborative_draft.state }
        let(:id) { collaborative_draft.id }
        let(:current_user) { create(:user, organization:) }
        let(:requester_user) { create(:user, organization:) }
        let(:requester_user_id) { requester_user.id }
        let(:params) do
          {
            state:,
            requester_user_id:,
            id:
          }
        end

        let(:form) do
          described_class.from_params(params)
        end

        before do
          collaborative_draft.collaborator_requests.create!(user: requester_user)
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when the state is not valid" do
          let(:state) { "foo" }

          it { is_expected.to be_invalid }
        end

        context "when there's no state" do
          let(:state) { nil }

          it { is_expected.to be_invalid }
        end

        context "when there's no collaborative_draft id" do
          let(:id) { nil }

          it { is_expected.to be_invalid }
        end

        context "when there's no requester user id" do
          let(:requester_user_id) { nil }

          it { is_expected.to be_invalid }
        end

        context "when the requester user is not a requester" do
          let(:not_requester_user) { create(:user, organization:) }
          let(:requester_user_id) { not_requester_user.id }

          it { is_expected.to be_invalid }
        end
      end
    end
  end
end
