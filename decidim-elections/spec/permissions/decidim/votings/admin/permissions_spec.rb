# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, :admin, organization: organization }
  let(:organization) { create :organization }
  let(:voting) { create :voting, organization: organization }
  let(:context) { { participatory_space: voting }.merge(extra_context) }
  let(:extra_context) { {} }
  let(:permission_action) { Decidim::PermissionAction.new(action) }
  let(:action) do
    { scope: :admin, action: action_name, subject: action_subject }
  end

  context "when the action is not for the admin part" do
    let(:action) do
      { scope: :public, action: :foo, subject: :bar }
    end

    it_behaves_like "permission is not set"
  end

  context "when the user is not an admin" do
    let(:user) { create :user, organization: organization }
    let(:action) do
      { scope: :admin, action: :foo, subject: :bar }
    end

    it { is_expected.to eq false }
  end

  describe "participatory spaces" do
    let(:action_subject) { :participatory_space }
    let(:action_name) { :read }

    it { is_expected.to eq true }
  end

  describe "components" do
    let(:action_subject) { :component }
    let(:action_name) { :manage }
    let(:extra_context) do
      { participatory_space: voting }
    end

    it { is_expected.to eq true }
  end

  describe "votings" do
    let(:action_subject) { :voting }

    context "when creating a voting" do
      let(:action_name) { :create }

      it { is_expected.to eq true }
    end

    context "when reading a voting" do
      let(:action_name) { :read }

      it { is_expected.to eq true }
    end
  end
end
