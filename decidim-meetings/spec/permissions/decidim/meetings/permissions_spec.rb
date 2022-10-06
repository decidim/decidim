# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:participatory_space) { create(:participatory_process, :with_steps) }
  let(:user) { create :user, organization: participatory_space.organization }
  let(:admin_user) { create :user, :admin, organization: participatory_space.organization }
  let(:context) do
    {
      current_component: meeting_component,
      component_settings:,
      meeting:,
      question:
    }
  end
  let(:component_settings) do
    double(creation_enabled_for_participants?: true)
  end
  let(:meeting_component) { create :meeting_component, participatory_space: }
  let(:meeting) { create :meeting, component: meeting_component }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }
  let(:poll) { create :poll, meeting: }
  let(:poll_questionnaire) { create :meetings_poll_questionnaire, questionnaire_for: poll }
  let(:question) { create :meetings_poll_question, questionnaire: poll_questionnaire }
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

  context "when subject is not a meeting and answer or a question" do
    let(:action) do
      { scope: :public, action: :vote, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  context "when answering a question" do
    let(:action) do
      { scope: :public, action: :create, subject: :answer }
    end

    context "when question not answered" do
      it { is_expected.to be true }
    end

    context "when question answered" do
      let!(:answer) { create :meetings_poll_answer, user:, question:, questionnaire: poll_questionnaire }

      it { is_expected.to be false }
    end
  end

  context "when updating a question" do
    let(:action) do
      { scope: :public, action: :update, subject: :question }
    end

    context "when user is not admin" do
      it { is_expected.to be false }
    end

    context "when user is admin" do
      let(:user) { admin_user }

      it { is_expected.to be true }
    end
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

      it { is_expected.to be false }
    end

    context "when meeting can be joined" do
      let(:can_be_joined) { true }

      it { is_expected.to be true }
    end
  end

  context "when registering on a meeting" do
    let(:action) do
      { scope: :public, action: :register, subject: :meeting }
    end

    before do
      allow(meeting)
        .to receive(:can_register_invitation?)
        .with(user)
        .and_return(can_be_registered)
    end

    context "when meeting can't be joined" do
      let(:can_be_registered) { false }

      it { is_expected.to be false }
    end

    context "when meeting can be joined" do
      let(:can_be_registered) { true }

      it { is_expected.to be true }
    end
  end

  context "when withdrawing a meeting" do
    let(:action) do
      { scope: :public, action: :withdraw, subject: :meeting }
    end

    context "when meeting author is the user trying to withdraw" do
      let(:meeting) { create :meeting, author: user, component: meeting_component }

      it { is_expected.to be true }
    end

    context "when trying by another user" do
      let(:user) { build :user }

      it { is_expected.to be false }
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

      it { is_expected.to be false }
    end

    context "when user is authorized" do
      it { is_expected.to be true }
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

      it { is_expected.to be false }
    end

    context "when user has not been invited" do
      it { is_expected.to be false }
    end

    context "when user has been invited" do
      before do
        meeting.invites << create(:invite, user:, meeting:)
      end

      it { is_expected.to be true }
    end
  end

  context "when creating meetings" do
    let(:action) do
      { scope: :public, action: :create, subject: :meeting }
    end

    context "when space is public and setting is enabled" do
      it { is_expected.to be true }
    end

    context "when space is private and setting is enabled" do
      let(:participatory_space) { create(:participatory_process, :with_steps, private_space: true) }
      let(:component_settings) do
        double(creation_enabled_for_participants?: true)
      end

      context "when user is not a member" do
        it { is_expected.to be false }
      end

      context "when user is admin and not a member" do
        let(:user) { admin_user }

        it { is_expected.to be false }
      end

      context "when user is admin but is a member" do
        let(:user) { admin_user }

        before do
          create(:participatory_space_private_user, user:, privatable_to: participatory_space)
        end

        it { is_expected.to be true }
      end

      context "when user is a space admin" do
        before do
          create(:participatory_process_user_role, user:, participatory_process: participatory_space)
        end

        it { is_expected.to be false }
      end

      context "when user is a space private participant" do
        before do
          create(:participatory_space_private_user, user:, privatable_to: participatory_space)
        end

        it { is_expected.to be true }
      end
    end

    context "when setting is disabled" do
      let(:component_settings) do
        double(creation_enabled_for_participants?: false)
      end

      it { is_expected.to be false }
    end
  end

  context "when updating a meeting" do
    let(:action) do
      { scope: :public, action: :update, subject: :meeting }
    end

    context "when setting is enabled" do
      context "when user is not the author" do
        it { is_expected.to be false }
      end

      context "when user is the author" do
        let(:meeting) { create :meeting, author: user, component: meeting_component }

        it { is_expected.to be true }

        context "when meeting is closed" do
          let(:meeting) { create :meeting, :closed, author: user, component: meeting_component }

          it { is_expected.to be false }
        end
      end
    end

    context "when setting is disabled" do
      let(:component_settings) do
        double(creation_enabled_for_participants?: false)
      end

      it { is_expected.to be false }
    end
  end

  context "when closing a meeting" do
    let(:action) do
      { scope: :public, action: :close, subject: :meeting }
    end

    context "when setting is enabled" do
      context "when user is not the author" do
        it { is_expected.to be false }
      end

      context "when user is the author" do
        let(:meeting) { create :meeting, author: user, component: meeting_component, closed_at: }

        context "when meeting is closed" do
          let(:closed_at) { Time.current }

          it { is_expected.to be false }
        end

        context "when meeting is not closed" do
          let(:closed_at) { nil }

          context "when meeting didn't finish" do
            before do
              allow(meeting).to receive(:past?).and_return(false)
            end

            it { is_expected.to be false }
          end

          context "when meeting did finish" do
            before do
              allow(meeting).to receive(:past?).and_return(true)
            end

            it { is_expected.to be true }
          end
        end
      end
    end

    context "when setting is disabled" do
      let(:component_settings) do
        double(creation_enabled_for_participants?: false)
      end

      it { is_expected.to be false }
    end
  end
end
