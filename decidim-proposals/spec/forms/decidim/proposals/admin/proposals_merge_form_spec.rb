# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe ProposalsMergeForm do
        subject { form }

        let(:organization) { create(:organization) }
        let(:proposals) { create_list(:proposal, 3, component:) }
        let(:component) { create(:proposal_component) }
        let(:target_component) { create(:proposal_component, participatory_space: component.participatory_space) }
        let(:params) do
          {
            target_component_id: [target_component.try(:id).to_s],
            proposal_ids: proposals.map(&:id),
            title: { "en" => "Valid Long Proposal Title" },
            body: { "en" => "Valid body text" }
          }
        end

        let(:form) do
          described_class.from_params(params).with_context(
            current_organization: organization,
            current_component: component,
            current_participatory_space: component.participatory_space
          )
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "without a target component" do
          let(:target_component) { nil }

          it { is_expected.to be_invalid }
        end

        context "when not enough proposals" do
          let(:proposals) { create_list(:proposal, 1, component:) }

          it { is_expected.to be_invalid }
        end

        context "when given a target component from another space" do
          let(:target_component) { create(:proposal_component) }

          it { is_expected.to be_invalid }
        end

        context "when merging to the same component" do
          let(:target_component) { component }
          let(:proposals) { create_list(:proposal, 3, :official, component:) }

          context "when the proposal is not official" do
            let(:proposals) { create_list(:proposal, 3, component:) }

            it { is_expected.to be_valid }
          end

          context "when a proposal has a vote" do
            before do
              create(:proposal_vote, proposal: proposals.sample)
            end

            it { is_expected.to be_invalid }
          end

          context "when a proposal has a like" do
            before do
              create(:like, resource: proposals.sample, author: create(:user, organization: component.participatory_space.organization))
            end

            it { is_expected.to be_valid }
          end
        end
      end
    end
  end
end
