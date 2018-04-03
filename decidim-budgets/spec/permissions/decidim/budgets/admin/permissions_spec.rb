# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).allowed? }

  let(:user) { build :user }
  let(:space_allows) { true }
  let(:context) do
    {
      current_component: budget_component,
      project: project
    }
  end
  let(:project) { create :project, component: budget_component }
  let(:budget_component) { create :budget_component }
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
      { scope: :admin, action: :foo, subject: :project }
    end

    it { is_expected.to eq false }
  end

  context "when scope is not admin" do
    let(:action) do
      { scope: :foo, action: :vote, subject: :project }
    end

    it { is_expected.to eq false }
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

      it { is_expected.to eq false }
    end
  end

  describe "project deletion" do
    let(:action) do
      { scope: :admin, action: :destroy, subject: :project }
    end

    it { is_expected.to eq true }

    context "when project is not present" do
      let(:project) { nil }

      it { is_expected.to eq false }
    end
  end
end
