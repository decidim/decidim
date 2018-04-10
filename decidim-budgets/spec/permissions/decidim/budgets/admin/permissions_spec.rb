# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { build :user }
  let(:context) do
    {
      current_component: budget_component,
      project: project
    }
  end
  let(:project) { create :project, component: budget_component }
  let(:budget_component) { create :budget_component }
  let(:permission_action) { Decidim::PermissionAction.new(action) }

  context "when scope is not admin" do
    let(:action) do
      { scope: :foo, action: :vote, subject: :project }
    end

    it_behaves_like "permission is not set"
  end

  describe "project creation" do
    let(:action) do
      { scope: :admin, action: :create, subject: :project }
    end

    it { is_expected.to eq true }
  end

  describe "project update" do
    let(:action) do
      { scope: :admin, action: :update, subject: :project }
    end

    it { is_expected.to eq true }

    context "when project is not present" do
      let(:project) { nil }

      it_behaves_like "permission is not set"
    end
  end

  describe "project deletion" do
    let(:action) do
      { scope: :admin, action: :destroy, subject: :project }
    end

    it { is_expected.to eq true }

    context "when project is not present" do
      let(:project) { nil }

      it_behaves_like "permission is not set"
    end
  end
end
