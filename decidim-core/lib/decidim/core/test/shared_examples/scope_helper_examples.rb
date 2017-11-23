# frozen_string_literal: true

require "spec_helper"

shared_examples "scope helpers" do
  let(:organization) { create(:organization) }
  let(:scopes_enabled) { true }
  let(:participatory_space_scope) { nil }
  let(:feature) { create(:feature, manifest_name: "dummy", participatory_space: participatory_space) }
  let(:scope) { create(:scope, organization: organization) }
  let(:resource) { create(:dummy_resource, feature: feature, scope: scope) }

  subject { helper.has_visible_scopes?(resource) }

  before do
    allow(helper).to receive(:current_participatory_space).and_return(participatory_space)
  end

  describe "has_visible_scopes?" do
    context "when all conditions are met" do
      it { is_expected.to be_truthy }
    end

    context "when the process has not scope enabled" do
      let(:scopes_enabled) { false }
      it { is_expected.to be_falsey }
    end

    context "when the process has a scope" do
      let(:participatory_space_scope) { create(:scope, organization: organization) }
      it { is_expected.to be_falsey }
    end

    context "when the resource has not a scope" do
      let(:scope) { nil }
      it { is_expected.to be_falsey }
    end
  end
end
