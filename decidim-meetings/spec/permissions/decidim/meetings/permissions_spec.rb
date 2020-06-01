# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, organization: meeting_component.organization }
  let(:context) do
    {
      current_component: meeting_component,
      component_settings: component_settings,
      meeting: meeting
    }
  end
  let(:component_settings) do
    double(creation_enabled_for_participants?: true)
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

  context "when declining an invitation" do
    let(:action) do
      { scope: :public, action: :decline_invitation, subject: :meeting }
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

    context "when user has not been invited" do
      it { is_expected.to eq false }
    end

    context "when user has been invited" do
      before do
        meeting.invites << create(:invite, user: user, meeting: meeting)
      end

      it { is_expected.to eq true }
    end
  end

  context "when creating meetings" do
    let(:action) do
      { scope: :public, action: :create, subject: :meeting }
    end

    context "when setting is enabled" do
      it { is_expected.to eq true }
    end

    context "when setting is disabled" do
      let(:component_settings) do
        double(creation_enabled_for_participants?: false)
      end

      it { is_expected.to eq false }
    end
  end

  context "when updating a meeting" do
    let(:action) do
      { scope: :public, action: :update, subject: :meeting }
    end

    context "when setting is enabled" do
      context "when user is not the organizer" do
        it { is_expected.to eq false }
      end

      context "when user is the organizer" do
        let(:meeting) { create :meeting, organizer: user, component: meeting_component }

        it { is_expected.to eq true }
      end
    end

    context "when setting is disabled" do
      let(:component_settings) do
        double(creation_enabled_for_participants?: false)
      end

      it { is_expected.to eq false }
    end
  end
end
