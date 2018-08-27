# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalWizardCreateStepForm do
      subject { form }

      let(:params) do
        {
          title: title,
          body: body,
          user_group_id: user_group.id
        }
      end

      let(:organization) { create(:organization, available_locales: [:en]) }
      let(:participatory_space) { create(:participatory_process, :with_steps, organization: organization) }
      let(:component) { create(:proposal_component, participatory_space: participatory_space) }
      let(:title) { "More sidewalks and less roads" }
      let(:body) { "Cities need more people, not more cars" }
      let(:author) { create(:user, organization: organization) }
      let(:user_group) { create(:user_group, :verified, users: [author], organization: organization) }

      let(:form) do
        described_class.from_params(params).with_context(
          current_component: component,
          current_organization: component.organization,
          current_participatory_space: participatory_space
        )
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when there's no title" do
        let(:title) { nil }

        it { is_expected.to be_invalid }

        it "only adds errors to this field" do
          subject.valid?
          expect(subject.errors.keys).to eq [:title]
        end
      end

      context "when there's no body" do
        let(:body) { nil }

        it { is_expected.to be_invalid }
      end

      context "when the body exceed the permited length" do
        let(:component) { create(:proposal_component, :with_proposal_length, participatory_space: participatory_space, proposal_length: 15) }
        let(:body) { "A body longer than the permitted" }

        it { is_expected.to be_invalid }
      end
    end
  end
end
