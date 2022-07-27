# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalWizardCreateStepForm do
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

      context "when there's no title" do
        let(:title) { nil }

        it { is_expected.to be_invalid }

        it "only adds errors to this field" do
          subject.valid?
          expect(subject.errors.attribute_names).to eq [:title]
        end
      end

      context "when there's no body" do
        let(:body) { nil }

        it { is_expected.to be_invalid }
      end

      context "when the body exceeds the permited length" do
        let(:component) { create(:proposal_component, :with_proposal_length, participatory_space:, proposal_length: allowed_length) }
        let(:allowed_length) { 15 }
        let(:body) { "A body longer than the permitted" }

        it { is_expected.to be_invalid }

        context "with carriage return characters that cause it to exceed" do
          let(:allowed_length) { 80 }
          let(:body) { "This text is just the correct length\r\nwith the carriage return characters removed" }

          it { is_expected.to be_valid }
        end
      end

      context "when there's a body template set" do
        let(:body_template) { "This is the template" }

        it { is_expected.to be_valid }

        context "when the template and the body are the same" do
          let(:body) { body_template }

          it { is_expected.to be_invalid }
        end
      end
    end
  end
end
