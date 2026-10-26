# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create(:user, organization: budgets_component.organization) }
  let(:context) do
    {
      current_component: budgets_component,
      project:
    }
  end
  let(:budgets_component) { create(:budgets_component) }
  let(:project) { create(:project, component: budgets_component) }
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

  context "when destroying an order" do
    let(:action) do
      { scope: :public, action: :destroy, subject: :order }
    end
    let(:budget) { create(:budget, component: budgets_component) }
    let(:order) { create(:order, user:, budget:) }
    let(:current_settings) { double(votes: "enabled") }
    let(:context) do
      {
        current_component: budgets_component,
        current_settings:,
        order:
      }
    end

    it { is_expected.to be true }

    context "when the order belongs to another user" do
      let(:order) { create(:order, budget:) }

      it { is_expected.to be false }
    end

    context "when the user is not signed in" do
      let(:user) { nil }
      let(:order) { create(:order, budget:) }

      it_behaves_like "permission is not set"
    end

    context "when voting is closed" do
      let(:current_settings) { double(votes: "disabled") }

      it { is_expected.to be false }
    end
  end

  context "when reading an order" do
    let(:action) do
      { scope: :public, action: :read, subject: :order }
    end
    let(:budget) { create(:budget, component: budgets_component) }
    let(:order) { create(:order, user:, budget:) }
    let(:context) do
      {
        current_component: budgets_component,
        order:
      }
    end

    it "allows the order owner" do
      expect(subject).to be true
    end

    context "when the order belongs to another user" do
      let(:order) { create(:order, budget:) }

      it { is_expected.to be false }
    end

    context "when the user is not signed in" do
      let(:user) { nil }
      let(:order) { create(:order, budget:) }

      it_behaves_like "permission is not set"
    end
  end

  context "when reading a budget" do
    let(:action) do
      { scope: :public, action: :read, subject: :budget }
    end
    let(:budget) { create(:budget, component: budgets_component) }
    let(:context) do
      {
        current_component: budgets_component,
        budget:
      }
    end

    it { is_expected.to be true }

    context "when the budget is deleted" do
      before do
        allow(budget).to receive(:deleted?).and_return(true)
      end

      it { is_expected.to be false }
    end
  end

  context "when reading a project" do
    let(:action) do
      { scope: :public, action: :read, subject: :project }
    end

    context "when listing projects without a specific project" do
      let(:context) do
        {
          current_component: budgets_component,
          project: nil
        }
      end

      it { is_expected.to be true }
    end

    context "when the project is not visible" do
      before do
        allow(project).to receive(:visible?).and_return(false)
      end

      it { is_expected.to be false }
    end
  end
end
