# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, organization: meeting_component.organization }
  let(:context) do
    {
      current_component: meeting_component,
      meeting: meeting
    }
  end
  let(:meeting_component) { create :meeting_component }
  let(:meeting) { create :meeting, component: meeting_component }
  let(:permission_action) { Decidim::PermissionAction.new(action) }
  let(:registrations_enabled) { true }

  context "when scope is admin" do
    let(:action) do
      { scope: :admin, action: :vote, subject: :meeting }
    end

    it_behaves_like "delegates permissions to", Decidim::Meetings::Admin::Permissions
  end

  context "when scope is not public" do
    let(:action) do
      { scope: :foo, action: :vote, subject: :meeting }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not a meeting" do
    let(:action) do
      { scope: :public, action: :vote, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  context "when joining a meeting" do
    let(:action) do
      { scope: :public, action: :join, subject: :meeting }
    end

    before do
      allow(meeting)
        .to receive(:can_be_joined_by?)
        .with(user)
        .and_return(can_be_joined)
    end

    context "when meeting can't be joined" do
      let(:can_be_joined) { false }

      it { is_expected.to eq false }
    end

    context "when meeting can be joined" do
      let(:can_be_joined) { true }

      it { is_expected.to eq true }
    end
  end

  context "when leaving a meeting" do
    let(:action) do
      { scope: :public, action: :leave, subject: :meeting }
    end

    before do
      allow(meeting)
        .to receive(:registrations_enabled?)
        .and_return(registrations_enabled)
    end

    context "when registrations are disabled" do
      let(:registrations_enabled) { false }

      it { is_expected.to eq false }
    end

    context "when user is authorized" do
      it { is_expected.to eq true }
    end
  end
end
