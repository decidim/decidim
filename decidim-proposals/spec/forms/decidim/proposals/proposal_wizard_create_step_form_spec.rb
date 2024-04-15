# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalForm do
      subject { form }

      let(:params) do
        {
          title:,
          body:,
          body_template:,
          user_group_id: user_group.id
        }
      end

      let(:organization) { create(:organization, available_locales: [:en]) }
      let(:participatory_space) { create(:participatory_process, :with_steps, organization:) }
      let(:component) { create(:proposal_component, participatory_space:) }
      let(:title) { "More sidewalks and less roads" }
      let(:body) { "Cities need more people, not more cars" }
      let(:body_template) { nil }
      let(:author) { create(:user, organization:) }
      let(:user_group) { create(:user_group, :verified, users: [author], organization:) }

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

      context "when there is no title" do
        let(:title) { nil }

        it { is_expected.to be_invalid }

        it "only adds errors to this field" do
          subject.valid?
          expect(subject.errors.attribute_names).to eq [:title]
        end
      end

      context "when there is no body" do
        let(:body) { nil }

        it { is_expected.to be_invalid }
      end
    end
  end
end
