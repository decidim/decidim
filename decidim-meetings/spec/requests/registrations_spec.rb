# frozen_string_literal: true

require "spec_helper"

describe "Meeting registrations" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }
  let(:participatory_process) { create(:participatory_process, :published, organization:) }
  let(:component) { create(:meeting_component, :published, participatory_space: participatory_process) }
  let(:meeting) { create(:meeting, :published, :online, component:, registrations_enabled: true, available_slots: 10) }
  let(:meeting_path) { Decidim::EngineRouter.main_proxy(component).meeting_path(meeting) }
  let(:registration_path) { Decidim::EngineRouter.main_proxy(component).meeting_registration_path(meeting_id: meeting.id) }

  before do
    host! organization.host
    login_as user, scope: :user
  end

  describe "POST create" do
    context "when there are no available slots" do
      before { create_list(:registration, 10, meeting:) }

      it "shows the alert on the meeting page" do
        post(registration_path)

        expect(response).to redirect_to(meeting_path)
        follow_redirect!

        expect(response.body).to include(I18n.t("registrations.create.invalid", scope: "decidim.meetings"))
      end
    end
  end

  describe "POST join_waitlist" do
    context "when the user cannot join the waitlist" do
      before do
        create_list(:registration, 10, meeting:)
        allow(Decidim::Meetings).to receive(:waiting_list_enabled).and_return(true)
        stub_command_broadcast(Decidim::Meetings::JoinWaitlist, :invalid)
      end

      it "shows the alert on the meeting page" do
        post(Decidim::EngineRouter.main_proxy(component).join_waitlist_meeting_registration_path(meeting_id: meeting.id))

        expect(response).to redirect_to(meeting_path)
        follow_redirect!

        expect(response.body).to include(I18n.t("registrations.waitlist.invalid", scope: "decidim.meetings"))
      end
    end
  end

  describe "DELETE destroy" do
    context "when the user has no registration" do
      it "shows the alert on the meeting page" do
        delete(registration_path)

        expect(response).to redirect_to(meeting_path)
        follow_redirect!

        expect(response.body).to include(I18n.t("registrations.destroy.invalid", scope: "decidim.meetings"))
      end
    end
  end

  describe "GET decline_invitation" do
    context "when the invitation cannot be declined" do
      before do
        create(:invite, meeting:, user:)
        stub_command_broadcast(Decidim::Meetings::DeclineInvitation, :invalid)
      end

      it "shows the alert on the meeting page" do
        get(Decidim::EngineRouter.main_proxy(component).decline_invitation_meeting_registration_path(meeting_id: meeting.id))

        expect(response).to redirect_to(meeting_path)
        follow_redirect!

        expect(response.body).to include(I18n.t("registrations.decline_invitation.invalid", scope: "decidim.meetings"))
      end
    end
  end
end
