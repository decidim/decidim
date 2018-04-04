# frozen_string_literal: true

require "spec_helper"

describe Decidim::Sortitions::Permissions do
  subject { described_class.new(user, permission_action, context).allowed? }

  let(:user) { create :user, organization: sortition_component.organization }
  let(:space_allows) { true }
  let(:context) do
    {
      current_component: sortition_component,
      sortition: sortition
    }
  end
  let(:sortition_component) { create :sortition_component }
  let(:sortition) { create :sortition, component: sortition_component }
  let(:permission_action) { Decidim::PermissionAction.new(action) }
  let(:space_permissions) { instance_double(Decidim::ParticipatoryProcesses::Permissions, allowed?: space_allows) }
  let(:registrations_enabled) { true }

  before do
    allow(Decidim::ParticipatoryProcesses::Permissions)
      .to receive(:new)
      .and_return(space_permissions)
  end

  context "when space does not allow the user to perform the action" do
    let(:space_allows) { false }
    let(:action) do
      { scope: :public, action: :foo, subject: :sortition }
    end

    it { is_expected.to eq false }
  end

  context "when scope is admin" do
    let(:action) do
      { scope: :admin, action: :vote, subject: :sortition }
    end

    it "delegates the check to the admin permissions class" do
      admin_permissions = instance_double(Decidim::Sortitions::Admin::Permissions, allowed?: true)
      allow(Decidim::Sortitions::Admin::Permissions)
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
      { scope: :foo, action: :blah, subject: :sortition }
    end

    it { is_expected.to eq false }
  end
end
