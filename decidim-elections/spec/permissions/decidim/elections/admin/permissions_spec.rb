# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create(:user, organization: component.organization) }
  let(:component) { create(:elections_component) }
  let(:election) { create(:election, component:) }
  let(:context) do
    {
      current_component: component,
      election:
    }
  end
  let(:permission_action) { Decidim::PermissionAction.new(scope: :admin, action: action_name, subject: action_subject) }
  let(:action_name) { :foo }
  let(:action_subject) { :foo }

  shared_examples "requires an election" do
    context "when election is present" do
      it { is_expected.to be true }
    end

    context "when election is missing" do
      let(:election) { nil }

      it { is_expected.to be false }
    end
  end

  context "when scope is not admin" do
    let(:permission_action) { Decidim::PermissionAction.new(scope: :public, action: :create, subject: :election) }

    it_behaves_like "permission is not set"
  end

  context "when subject is unknown" do
    let(:action_subject) { :unknown }

    it_behaves_like "permission is not set"
  end

  context "when subject is election" do
    let(:action_subject) { :election }

    context "when creating" do
      let(:action_name) { :create }

      it { is_expected.to be true }
    end

    context "when reading" do
      let(:action_name) { :read }

      it { is_expected.to be true }
    end

    context "when updating" do
      let(:action_name) { :update }

      it_behaves_like "requires an election"
    end
  end

  context "when subject is election_question" do
    let(:action_subject) { :election_question }

    context "when updating" do
      let(:action_name) { :update }

      it_behaves_like "requires an election"
    end

    context "when reordering" do
      let(:action_name) { :reorder }

      it_behaves_like "requires an election"
    end
  end
end
