# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { build :user }
  let(:context) do
    {
      current_component: budgets_component,
      budget:,
      project:
    }
  end
  let(:budgets_component) { create :budgets_component }
  let(:budget) { create :budget, component: budgets_component }
  let(:project) { create :project, component: budgets_component }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  context "when scope and action are both random" do
    let(:action) do
      { scope: :foo, action: :bar, subject: :budget }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not a budget" do
    let(:action) do
      { scope: :admin, action: :bar, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  context "when action is a random one" do
    let(:action) do
      { scope: :admin, action: :bar, subject: :budget }
    end

    it_behaves_like "permission is not set"
  end

  describe "budget creation" do
    let(:action) do
      { scope: :admin, action: :create, subject: :budget }
    end
    let(:budget) { nil }

    it { is_expected.to be true }
  end

  describe "budget update" do
    let(:action) do
      { scope: :admin, action: :update, subject: :budget }
    end

    it { is_expected.to be true }
  end

  context "when deleting a budget" do
    describe "with no projects" do
      let(:action) do
        { scope: :admin, action: :delete, subject: :budget }
      end

      it { is_expected.to be true }
    end

    describe "with projects" do
      let(:budget) { create :budget, :with_projects, component: budgets_component }
      let(:action) do
        { scope: :admin, action: :delete, subject: :budget }
      end

      it { is_expected.to be false }
    end
  end

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

    it { is_expected.to be true }
  end

  describe "project update" do
    let(:action) do
      { scope: :admin, action: :update, subject: :project }
    end

    it { is_expected.to be true }

    context "when project is not present" do
      let(:project) { nil }

      it_behaves_like "permission is not set"
    end
  end

  describe "project deletion" do
    let(:action) do
      { scope: :admin, action: :destroy, subject: :project }
    end

    it { is_expected.to be true }

    context "when project is not present" do
      let(:project) { nil }

      it_behaves_like "permission is not set"
    end
  end
end
