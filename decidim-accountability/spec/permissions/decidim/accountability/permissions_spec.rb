# frozen_string_literal: true

require "spec_helper"

describe Decidim::Accountability::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, organization: accountability_component.organization }
  let(:context) do
    {
      current_component: accountability_component
    }
  end
  let(:accountability_component) { create :accountability_component }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  context "when scope is admin" do
    let(:action) do
      { scope: :admin, action: :vote, subject: :proposal }
    end

    it_behaves_like "delegates permissions to", Decidim::Accountability::Admin::Permissions
  end

  context "when any other condition" do
    let(:action) do
      { scope: :public, action: :foo, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end
end
