# frozen_string_literal: true

require "spec_helper"

describe Decidim::ScopesHelper do
  let(:organization) { create(:organization) }
  let(:scopes_enabled) { true }
  let(:process_scope) { nil }
  let(:participatory_process) { create(:participatory_process, organization: organization, scopes_enabled: scopes_enabled, scope: process_scope) }
  let(:feature) { create(:feature, manifest_name: "dummy", participatory_process: participatory_process) }
  let(:scope) { create(:scope, organization: organization) }
  let(:resource) { create(:dummy_resource, feature: feature, scope: scope) }

  subject { helper.has_visible_scope?(resource) }

  before do
    allow(helper).to receive(:current_participatory_process).and_return(participatory_process)
  end

  describe "has_visible_scope?" do
    context "when all conditions are met" do
      it { is_expected.to be_truthy }
    end

    context "when the process has not scope enabled" do
      let(:scopes_enabled) { false }
      it { is_expected.to be_falsey }
    end

    context "when the process has a scope" do
      let(:process_scope) { create(:scope, organization: organization) }
      it { is_expected.to be_falsey }
    end

    context "when the resource has not a scope" do
      let(:scope) { nil }
      it { is_expected.to be_falsey }
    end
  end
end
