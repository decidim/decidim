# frozen_string_literal: true

require "spec_helper"

describe Decidim::Templates::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, organization:) }
  let(:context) do
    {
      current_organization: organization
    }
  end
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  context "when scope is not admin" do
    let(:action) do
      { scope: :foo, action: :read, subject: :template }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not a template" do
    let(:action) do
      { scope: :admin, action: :read, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  context "when action is a random one" do
    let(:action) do
      { scope: :admin, action: :foo, subject: :template }
    end

    it_behaves_like "permission is not set"
  end

  context "when user is not admin" do
    let(:user) { create(:user, :confirmed, organization:) }
    let(:action) do
      { scope: :admin, action: :read, subject: :template }
    end

    it_behaves_like "permission is not set"
  end

  shared_examples_for "action is allowed" do |scope, action, subject|
    let(:action) do
      { scope:, action:, subject: }
    end

    it { is_expected.to be true }
  end

  context "when user is admin" do
    let(:user) { create(:user, :admin, organization:) }

    it_behaves_like "action is allowed", :admin, :index, :templates
  end

  context "when indexing templates" do
    it_behaves_like "action is allowed", :admin, :index, :templates
  end

  context "when reading a template" do
    it_behaves_like "action is allowed", :admin, :read, :template

    context "when user is a evaluator" do
      let(:user) { create(:user, :confirmed, organization:) }
      let!(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user:, participatory_process: participatory_space) }
      let!(:evaluation_assignment) { create(:evaluation_assignment, proposal:, evaluator_role:) }
      let(:proposal) { create(:proposal, component:) }
      let(:component) { create(:proposal_component, participatory_space:) }
      let(:participatory_space) { create(:participatory_process, organization:) }
      let(:action) do
        { scope: :admin, action: action_str, subject: :template }
      end
      let(:context) do
        {
          current_organization: organization,
          proposal:
        }
      end

      let(:action_str) { :read }

      it { is_expected.to be true }

      context "when other actions" do
        let(:action_str) { :index }

        it_behaves_like "permission is not set"
      end
    end
  end

  context "when creating a template" do
    it_behaves_like "action is allowed", :admin, :create, :template
  end

  context "when copying a template" do
    it_behaves_like "action is allowed", :admin, :copy, :template
  end

  context "when updating a template" do
    it_behaves_like "action is allowed", :admin, :update, :template
  end

  context "when destroying a template" do
    it_behaves_like "action is allowed", :admin, :destroy, :template
  end

  context "when subject is a questionnaire" do
    let(:action) do
      { scope: :admin, action: :foo, subject: :questionnaire }
    end

    it { is_expected.to be true }
  end
end
