# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe ProposalAnswerForm do
        subject { form }

        let(:organization) { create(:organization) }
        let(:state) { "accepted" }
        let(:answer) { Decidim::Faker::Localized.sentence(3) }
        let(:params) do
          {
            state: state, answer: answer
          }
        end

        let(:form) do
          described_class.from_params(params).with_context(
            current_organization: organization
          )
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

        context "when rejecting a proposal" do
          let(:state) { "rejected" }

          context "and there's no answer" do
            let(:answer) { nil }

            it { is_expected.to be_invalid }
          end
        end
      end
    end
  end
end
