# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Groups::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, organization: budget_component.organization }
  let(:parent_component) { create :budgets_group_component, :with_children }
  let(:budget_component) { parent_component.children.first }
  let(:allowed) { true }
  let(:context) do
    {
      current_component: budget_component,
      project: project,
      parent_component_context: {
        workflow_instance: double.tap do |mock|
                             allow(mock).to receive(:vote_allowed?).and_return(allowed)
                           end
      }
    }
  end
  let(:project) { create :project, component: budget_component }
  let(:permission_action) { Decidim::PermissionAction.new(action) }

  context "when scope is not public" do
    let(:action) do
      { scope: :foo, action: :vote, subject: :project }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not a project nor an order" do
    let(:action) do
      { scope: :public, action: :vote, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  context "when voting a project" do
    let(:action) do
      { scope: :public, action: :vote, subject: :project }
    end

    it_behaves_like "permission is not set"
  end

  context "when creating an order" do
    let(:action) do
      { scope: :public, action: :create, subject: :order }
    end

    it { is_expected.to eq true }
  end

  context "when workflow disallows" do
    let(:allowed) { false }

    context "when voting a project" do
      let(:action) do
        { scope: :public, action: :vote, subject: :project }
      end

      it { is_expected.to eq false }
    end

    context "when creating an order" do
      let(:action) do
        { scope: :public, action: :create, subject: :order }
      end

      it { is_expected.to eq false }
    end
  end
end
