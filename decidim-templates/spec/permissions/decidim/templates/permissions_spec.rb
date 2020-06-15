# frozen_string_literal: true

require "spec_helper"

describe Decidim::Templates::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:organization) { create :organization }
  let(:user) { create :user, organization: organization }
  let(:context) do
    {
      current_organization: create(:organization)
    }
  end
  let(:permission_action) { Decidim::PermissionAction.new(action) }

  context "when scope is admin" do
    let(:action) do
      { scope: :admin, action: :read, subject: :template }
    end

    it_behaves_like "delegates permissions to", Decidim::Templates::Admin::Permissions
  end

  context "when scope is not public" do
    let(:action) do
      { scope: :foo, action: :read, subject: :template }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not a template" do
    let(:action) do
      { scope: :public, action: :read, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  context "when action is a random one" do
    let(:action) do
      { scope: :public, action: :foo, subject: :template }
    end

    it_behaves_like "permission is not set"
  end
end
