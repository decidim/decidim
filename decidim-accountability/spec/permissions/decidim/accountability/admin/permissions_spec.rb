# frozen_string_literal: true

require "spec_helper"

describe Decidim::Accountability::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { build :user }
  let(:context) do
    {
      current_component: accountability_component
    }.merge(extra_context)
  end
  let(:extra_context) { {} }
  let(:accountability_component) { create :accountability_component }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  shared_examples "crud permissions" do
    describe "create" do
      let(:action) do
        { scope: :admin, action: :create, subject: action_subject }
      end

      it { is_expected.to be true }
    end

    describe "update" do
      let(:action) do
        { scope: :admin, action: :update, subject: action_subject }
      end

      context "when the resource is present" do
        it { is_expected.to be true }
      end

      context "when the resource is not present" do
        let(:resource) { nil }

        it_behaves_like "permission is not set"
      end
    end

    describe "destroy" do
      let(:action) do
        { scope: :admin, action: :destroy, subject: action_subject }
      end

      context "when the resource is present" do
        it { is_expected.to be true }
      end

      context "when the resource is not present" do
        let(:resource) { nil }

        it_behaves_like "permission is not set"
      end
    end

    context "when any other action" do
      let(:action) do
        { scope: :admin, action: :foo, subject: :action_subject }
      end

      it_behaves_like "permission is not set"
    end
  end

  describe "result" do
    let(:resource) { create :result, component: accountability_component }
    let(:action_subject) { :result }
    let(:extra_context) { { result: resource } }

    it_behaves_like "crud permissions"

    describe "creating a children" do
      let(:resource) { create :result, component: accountability_component }
      let(:action_subject) { :result }
      let(:extra_context) { { result: resource } }
      let(:action) do
        { scope: :admin, action: :create_children, subject: action_subject }
      end

      it { is_expected.to be true }
    end

    describe "creating a grandchildren" do
      let(:parent_result) { create :result, component: accountability_component }
      let(:resource) { create :result, parent: parent_result }
      let(:action) do
        { scope: :admin, action: :create_children, subject: action_subject }
      end

      it_behaves_like "permission is not set"
    end
  end

  describe "status" do
    let(:resource) { create :status, component: accountability_component }
    let(:action_subject) { :status }
    let(:extra_context) { { status: resource } }

    it_behaves_like "crud permissions"
  end

  describe "timeline_entry" do
    let(:result) { create :result, component: accountability_component }
    let(:resource) { create :timeline_entry, result: result }
    let(:action_subject) { :timeline_entry }
    let(:extra_context) { { timeline_entry: resource } }

    it_behaves_like "crud permissions"
  end

  context "when any other condition" do
    let(:action) do
      { scope: :admin, action: :foo, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end
end
