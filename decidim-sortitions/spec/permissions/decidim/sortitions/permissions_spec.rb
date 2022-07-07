# frozen_string_literal: true

require "spec_helper"

describe Decidim::Sortitions::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, organization: sortition_component.organization }
  let(:context) do
    {
      current_component: sortition_component,
      sortition: sortition
    }
  end
  let(:sortition_component) { create :sortition_component }
  let(:sortition) { create :sortition, component: sortition_component }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }
  let(:registrations_enabled) { true }

  context "when scope is admin" do
    let(:action) do
      { scope: :admin, action: :vote, subject: :sortition }
    end

    it_behaves_like "delegates permissions to", Decidim::Sortitions::Admin::Permissions
  end

  context "when any other condition" do
    let(:action) do
      { scope: :foo, action: :blah, subject: :sortition }
    end

    it_behaves_like "permission is not set"
  end
end
