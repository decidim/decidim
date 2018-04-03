# frozen_string_literal: true

require "spec_helper"

describe Decidim::Accountability::Permissions do
  subject { described_class.new(user, permission_action, context).allowed? }

  let(:user) { create :user, organization: accountability_component.organization }
  let(:space_allows) { true }
  let(:context) do
    {
      current_component: accountability_component
    }
  end
  let(:accountability_component) { create :accountability_component }
  let(:permission_action) { Decidim::PermissionAction.new(action) }
  let(:space_permissions) { instance_double(Decidim::ParticipatoryProcesses::Permissions, allowed?: space_allows) }

  before do
    allow(Decidim::ParticipatoryProcesses::Permissions)
      .to receive(:new)
      .and_return(space_permissions)
  end

  context "when space does not allow the user to perform the action" do
    let(:space_allows) { false }
    let(:action) do
      { scope: :public, action: :foo, subject: :proposal }
    end

    it { is_expected.to eq false }
  end

  context "when scope is admin" do
    let(:action) do
      { scope: :admin, action: :vote, subject: :proposal }
    end
    let(:space_allows) { true }

    it "delegates the check to the admin permissions class" do
      admin_permissions = instance_double(Decidim::Accountability::Admin::Permissions, allowed?: true)
      allow(Decidim::Accountability::Admin::Permissions)
        .to receive(:new)
        .with(user, permission_action, context)
        .and_return admin_permissions

      expect(admin_permissions)
        .to receive(:allowed?)

      subject
    end
  end

  context "when any other condition" do
    let(:action) do
      { scope: :public, action: :foo, subject: :foo }
    end

    it { is_expected.to eq false }
  end
end
