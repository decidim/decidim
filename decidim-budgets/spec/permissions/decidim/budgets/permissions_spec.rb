# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Permissions do
  subject { described_class.new(user, permission_action, context).allowed? }

  let(:user) { create :user, organization: budget_component.organization }
  let(:space_allows) { true }
  let(:context) do
    {
      current_component: budget_component,
      project: project
    }
  end
  let(:budget_component) { create :budget_component }
  let(:project) { create :project, component: budget_component }
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
      { scope: :public, action: :foo, subject: :project }
    end

    it { is_expected.to eq false }
  end

  context "when scope is admin" do
    let(:action) do
      { scope: :admin, action: :vote, subject: :project }
    end
    let(:space_allows) { true }

    it "delegates the check to the admin permissions class" do
      admin_permissions = instance_double(Decidim::Budgets::Admin::Permissions, allowed?: true)
      allow(Decidim::Budgets::Admin::Permissions)
        .to receive(:new)
        .with(user, permission_action, context)
        .and_return admin_permissions

      expect(admin_permissions)
        .to receive(:allowed?)

      subject
    end
  end

  context "when scope is not public" do
    let(:action) do
      { scope: :foo, action: :vote, subject: :project }
    end

    it { is_expected.to eq false }
  end

  context "when subject is not a project" do
    let(:action) do
      { scope: :public, action: :vote, subject: :foo }
    end

    it { is_expected.to eq false }
  end

  context "when action is a random one" do
    let(:action) do
      { scope: :public, action: :foobar, subject: :project }
    end

    it { is_expected.to eq false }
  end

  context "when reporting a budget" do
    let(:action) do
      { scope: :public, action: :report, subject: :project }
    end

    it { is_expected.to eq true }
  end
end
