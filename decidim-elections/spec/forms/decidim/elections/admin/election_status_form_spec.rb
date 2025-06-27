# frozen_string_literal: true

require "spec_helper"

module Decidim::Elections
  describe Admin::ElectionStatusForm do
    subject { described_class.from_params(attributes).with_context(context) }

    let(:organization) { create(:organization) }
    let(:component) { create(:elections_component, organization:) }
    let(:context) do
      {
        current_organization: organization,
        current_component: component
      }
    end

    let(:status_action) { :start }
    let(:question_id) { 123 }

    let(:attributes) do
      {
        status_action:,
        question_id:
      }
    end

    it { is_expected.to be_valid }

    describe "when status_action is missing" do
      let(:status_action) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "when status_action is invalid" do
      let(:status_action) { :invalid_action }

      it { is_expected.not_to be_valid }
    end

    describe "when question_id is nil" do
      let(:question_id) { nil }

      it { is_expected.to be_valid }
    end

    describe "when question_id is present" do
      let(:question_id) { 42 }

      it { is_expected.to be_valid }
    end
  end
end
