# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, organization: meeting_component.organization }
  let(:space_allows) { true }
  let(:context) do
    {
      current_component: meeting_component,
      meeting:,
      agenda:,
      questionnaire:,
      poll:
    }
  end
  let(:meeting_component) { create :meeting_component }
  let(:meeting) { create :meeting, :official, component: meeting_component }
  let(:agenda) { create :agenda }
  let(:questionnaire) { create :questionnaire }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }
  let(:registrations_enabled) { true }
  let(:action) do
    { scope: :admin, action: action_name, subject: action_subject }
  end
  let(:poll) { create :poll }
  let(:poll_questionnaire) { create(:meetings_poll_questionnaire, questionnaire_for: poll) }
  let(:action_name) { :foo }
  let(:action_subject) { :foo }

  shared_examples "action requiring a meeting" do
    context "when meeting is present" do
      it { is_expected.to be true }
    end

    context "when meeting is missing" do
      let(:meeting) { nil }

      it { is_expected.to be false }
    end
  end

  shared_examples "action requiring an agenda" do
    context "when agenda is present" do
      it { is_expected.to be true }
    end

    context "when agenda is missing" do
      let(:agenda) { nil }

      it { is_expected.to be false }
    end
  end

  shared_examples "action requiring a questionnaire" do
    context "when registration form is present" do
      it { is_expected.to be true }
    end

    context "when registration form is missing" do
      let(:questionnaire) { nil }

      it { is_expected.to be false }
    end
  end

  context "when scope is not admin" do
    let(:action) do
      { scope: :foo, action: :create, subject: :meeting }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is a random one" do
    let(:action) do
      { scope: :admin, action: :create, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  context "when action is a random one" do
    let(:action) do
      { scope: :admin, action: :foo, subject: :meeting }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is a meeting" do
    let(:action_subject) { :meeting }

    context "when meeting is not official" do
      let(:meeting) { create :meeting, :not_official, component: meeting_component }
      let(:action_name) { :update }

      it { is_expected.to be false }
    end

    context "when creating a meeting" do
      let(:action_name) { :create }

      it { is_expected.to be true }
    end

    context "when closing a meeting" do
      let(:action_name) { :close }

      it_behaves_like "action requiring a meeting"
    end

    context "when copying a meeting" do
      let(:action_name) { :copy }

      it_behaves_like "action requiring a meeting"
    end

    context "when destroying a meeting" do
      let(:action_name) { :destroy }

      it_behaves_like "action requiring a meeting"
    end

    context "when exporting registrations a meeting" do
      let(:action_name) { :export_registrations }

      it_behaves_like "action requiring a meeting"
    end

    context "when inviting a user a meeting" do
      let(:action_name) { :invite_attendee }
      let(:meeting) { create :meeting, registrations_enabled: true, component: meeting_component }

      it_behaves_like "action requiring a meeting"

      context "when the meeting registrations are closed" do
        let(:meeting) { create :meeting, registrations_enabled: false, component: meeting_component }

        it { is_expected.to be false }
      end
    end

    context "when reading invites" do
      let(:action_name) { :read_invites }

      it_behaves_like "action requiring a meeting"
    end

    context "when updating a meeting" do
      let(:action_name) { :update }

      it_behaves_like "action requiring a meeting"
    end
  end

  context "when subject is the agenda" do
    let(:action_subject) { :agenda }

    context "when creating the agenda" do
      let(:action_name) { :create }

      it_behaves_like "action requiring a meeting"
    end

    context "when updating the agenda" do
      let(:action_name) { :update }

      it_behaves_like "action requiring a meeting"
      it_behaves_like "action requiring an agenda"
    end
  end

  context "when subject is a questionnaire" do
    let(:action_subject) { :questionnaire }

    context "when updating a questionnaire" do
      let(:action_name) { :update }

      it_behaves_like "action requiring a questionnaire"
    end
  end

  context "when subject is a poll" do
    let(:action_subject) { :poll }

    context "when updating a poll" do
      let(:action_name) { :update }

      context "when meeting is present and poll is present" do
        it_behaves_like "action requiring a meeting"
      end

      context "when poll is missing" do
        let(:poll) { nil }

        it { is_expected.to be false }
      end
    end
  end
end
