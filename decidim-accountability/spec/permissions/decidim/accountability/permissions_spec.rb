# frozen_string_literal: true

require "spec_helper"

describe Decidim::Accountability::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create(:user, organization: accountability_component.organization) }
  let(:context) do
    {
      current_component: accountability_component
    }
  end
  let(:accountability_component) { create(:accountability_component) }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  context "when scope is admin" do
    let(:action) do
      { scope: :admin, action: :vote, subject: :proposal }
    end

    it_behaves_like "delegates permissions to", Decidim::Accountability::Admin::Permissions
  end

  context "when reading results" do
    let(:action) do
      { scope: :public, action: :read, subject: :result }
    end

    context "when listing results" do
      it { is_expected.to be true }
    end

    context "when a deleted result is given" do
      let(:result) { create(:result, component: accountability_component) }
      let(:context) do
        {
          current_component: accountability_component,
          result:
        }
      end

      before do
        allow(result).to receive(:deleted?).and_return(true)
      end

      it { is_expected.to be false }
    end
  end

  context "when any other condition" do
    let(:action) do
      { scope: :public, action: :foo, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end
end
