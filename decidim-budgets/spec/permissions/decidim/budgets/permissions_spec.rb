# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, organization: budgets_component.organization }
  let(:context) do
    {
      current_component: budgets_component,
      project:
    }
  end
  let(:budgets_component) { create :budgets_component }
  let(:project) { create :project, component: budgets_component }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  context "when scope is admin" do
    let(:action) do
      { scope: :admin, action: :vote, subject: :project }
    end

    it_behaves_like "delegates permissions to", Decidim::Budgets::Admin::Permissions
  end

  context "when scope is not public" do
    let(:action) do
      { scope: :foo, action: :vote, subject: :project }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not a project" do
    let(:action) do
      { scope: :public, action: :vote, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  context "when action is a random one" do
    let(:action) do
      { scope: :public, action: :foobar, subject: :project }
    end

    it_behaves_like "permission is not set"
  end

  context "when reporting a budget" do
    let(:action) do
      { scope: :public, action: :report, subject: :project }
    end

    it { is_expected.to be true }
  end
end
