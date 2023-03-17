# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe RequestAccessToCollaborativeDraftForm do
        subject { form }

        let(:organization) { create(:organization) }
        let(:collaborative_draft) { create(:collaborative_draft, :open) }
        let(:state) { collaborative_draft.state }
        let(:id) { collaborative_draft.id }
        let(:current_user) { create(:user, organization:) }
        let(:params) do
          {
            state:,
            id:
          }
        end

        let(:form) do
          described_class.from_params(params)
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
      end
    end
  end
end
