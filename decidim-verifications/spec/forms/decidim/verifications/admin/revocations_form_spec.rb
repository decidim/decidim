# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications::Admin
  describe RevocationsForm do
    subject { described_class.from_params(params).with_context(current_organization: organization) }

    let(:organization) { create(:organization, available_authorizations: ["some_method"]) }
    let(:name) { "some_method" }
    let(:impersonated_only) { false }
    let(:before_date) { nil }
    let(:params) { { name:, impersonated_only:, before_date: } }

    it { is_expected.to be_valid }

    context "when name is blank" do
      let(:name) { "" }

      it { is_expected.to be_invalid }
    end

    context "when name is not an available authorization for the organization" do
      let(:name) { "unavailable_method" }

      it { is_expected.to be_invalid }
    end

    context "when impersonated_only is true" do
      let(:impersonated_only) { true }

      it { is_expected.to be_valid }
    end

    context "when before_date is present" do
      let(:before_date) { Time.zone.today.prev_week }

      it { is_expected.to be_valid }
    end

    context "when impersonated_only is not given" do
      subject { described_class.from_params(name:).with_context(current_organization: organization) }

      it "defaults to false" do
        expect(subject.impersonated_only).to be(false)
      end
    end
  end
end
