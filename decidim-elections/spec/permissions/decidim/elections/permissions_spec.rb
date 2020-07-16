# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, organization: elections_component.organization }
  let(:context) do
    {
      current_component: elections_component,
      election: election
    }
  end
  let(:elections_component) { create :elections_component }
  let(:election) { create :election, component: elections_component }
  let(:permission_action) { Decidim::PermissionAction.new(action) }

  shared_examples "allowed when election is ongoing" do
    context "when election is upcoming" do
      let(:election) { create :election, :upcoming, component: elections_component }

      it { is_expected.to be_falsey }
    end

    context "when election is ongoing" do
      let(:election) { create :election, component: elections_component }

      it { is_expected.to be_truthy }
    end

    context "when election has finished" do
      let(:election) { create :election, :finished, component: elections_component }

      it { is_expected.to be_falsey }
    end
  end

  context "when scope is admin" do
    let(:action) do
      { scope: :admin, action: :foo, subject: :election }
    end

    it_behaves_like "delegates permissions to", Decidim::Elections::Admin::Permissions
  end

  context "when scope is not public" do
    let(:action) do
      { scope: :foo, action: :bar, subject: :election }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not an election" do
    let(:action) do
      { scope: :public, action: :bar, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  context "when action is a random one" do
    let(:action) do
      { scope: :public, action: :bar, subject: :election }
    end

    it_behaves_like "permission is not set"
  end

  describe "election vote" do
    let(:action) do
      { scope: :public, action: :vote, subject: :election }
    end

    it_behaves_like "allowed when election is ongoing"
  end
end
