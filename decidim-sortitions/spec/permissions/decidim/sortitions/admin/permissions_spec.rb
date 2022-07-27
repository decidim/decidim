# frozen_string_literal: true

require "spec_helper"

describe Decidim::Sortitions::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, organization: sortition_component.organization }
  let(:context) do
    {
      current_component: sortition_component,
      sortition:
    }
  end
  let(:sortition_component) { create :sortition_component }
  let(:sortition) { create :sortition, component: sortition_component }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }
  let(:registrations_enabled) { true }
  let(:action) do
    { scope: :admin, action: action_name, subject: :sortition }
  end
  let(:action_name) { :foo }

  context "when scope is not admin" do
    let(:action) do
      { scope: :foo, action: :vote, subject: :sortition }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not a sortition" do
    let(:action) do
      { scope: :admin, action: :vote, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  context "when action is a random one" do
    let(:action_name) { :foo }

    it_behaves_like "permission is not set"
  end

  context "when reading a sortition" do
    let(:action_name) { :read }

    it { is_expected.to be true }
  end

  context "when creating a sortition" do
    let(:action_name) { :create }

    it { is_expected.to be true }
  end

  context "when destroying a sortition" do
    let(:action_name) { :destroy }

    context "when sortition is present" do
      context "when sortition is not cancelled" do
        it { is_expected.to be true }
      end

      context "when sortition is cancelled" do
        let(:sortition) { create :sortition, :cancelled, component: sortition_component }

        it_behaves_like "permission is not set"
      end
    end

    context "when sortition is missing" do
      let(:sortition) { nil }

      it_behaves_like "permission is not set"
    end
  end

  context "when updating a sortition" do
    let(:action_name) { :update }

    context "when sortition is present" do
      it { is_expected.to be true }
    end

    context "when sortition is missing" do
      let(:sortition) { nil }

      it_behaves_like "permission is not set"
    end
  end
end
