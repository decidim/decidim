# frozen_string_literal: true

require "spec_helper"

describe Decidim::Templates::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, organization: organization }
  let(:organization) { create :organization }
  let(:template) { create :template, organization: organization }
  let(:context) { { template: template }.merge(extra_context) }
  let(:extra_context) { {} }
  let(:permission_action) { Decidim::PermissionAction.new(action) }
  let(:action) do
    { scope: :admin, action: action_name, subject: action_subject }
  end

  context "when the action is not for the admin part" do
    let(:action) do
      { scope: :public, action: :foo, subject: :template }
    end

    it_behaves_like "permission is not set"
  end

  context "when user is not given" do
    let(:user) { nil }
    let(:action) do
      { scope: :admin, action: :foo, subject: :template }
    end

    it_behaves_like "permission is not set"
  end

  context "when user is admin" do
    let(:user) { create :user, :admin, organization: organization }

    context "when managing templates" do
      let(:action_subject) { :template }

      context "when indexing" do
        let(:action_name) { :index }

        it { is_expected.to eq true }
      end

      context "when reading" do
        let(:action_name) { :read }

        it { is_expected.to eq true }
      end

      context "when creating" do
        let(:action_name) { :create }

        it { is_expected.to eq true }
      end

      context "when destroying" do
        let(:action_name) { :destroy }

        it { is_expected.to eq true }
      end
    end
  end

  context "when any other condition" do
    let(:action) do
      { scope: :admin, action: :foo, subject: :bar }
    end

    it_behaves_like "permission is not set"
  end
end
