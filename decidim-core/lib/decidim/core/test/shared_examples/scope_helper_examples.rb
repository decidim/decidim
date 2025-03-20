# frozen_string_literal: true

require "spec_helper"

shared_examples "scope helpers" do
  let(:organization) { create(:organization) }
  let(:scopes_enabled) { true }
  let(:participatory_space_scope) { nil }
  let(:component_scope) { nil }
  let(:component) do
    create(
      :component,
      manifest_name: "dummy",
      participatory_space:,
      settings: { scopes_enabled:, scope_id: component_scope&.id }
    )
  end
  let(:scope) { create(:scope, organization:) }
  let(:subscope) { create(:subscope, organization:) }
  let(:resource) { create(:dummy_resource, component:, scope:) }

  before do
    allow(helper).to receive(:current_participatory_space).and_return(participatory_space)
  end

  let(:helper) do
    Class.new.tap do |v|
      v.extend(Decidim::ScopesHelper)
      v.extend(Decidim::TranslationsHelper)
    end
  end

  describe "has_visible_scopes?" do
    subject { helper.has_visible_scopes?(resource) }

    context "when all conditions are met" do
      it { is_expected.to be_truthy }
    end

    context "when the process has not scope enabled" do
      let(:scopes_enabled) { false }

      it { is_expected.to be_falsey }
    end

    context "when the process has a different scope than the organization" do
      let(:participatory_space_scope) { create(:scope, organization:) }
      let(:component_scope) { participatory_space_scope }

      it { is_expected.to be_truthy }
    end

    context "when the process has the same scope as the organization" do
      let(:participatory_space_scope) { scope }
      let(:component_scope) { scope }

      it { is_expected.to be_falsey }
    end

    context "when the resource has not a scope" do
      let(:scope) { nil }

      it { is_expected.to be_falsey }
    end
  end

  describe "scope_name_for_picker" do
    subject { helper.scope_name_for_picker(scope, global_name) }

    let(:global_name) { "Global name" }

    context "when a scope is given" do
      context "when the scope has a scope type" do
        it { is_expected.to include(scope.name["en"]) }
        it { is_expected.to include(scope.scope_type.name["en"]) }
      end

      context "when the scope has no type" do
        before do
          scope.scope_type = nil
        end

        it { is_expected.to eq(scope.name["en"]) }
      end
    end

    context "when no scope is given" do
      let(:scope) { nil }

      it { is_expected.to eq("Global name") }
    end
  end
end
