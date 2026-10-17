# frozen_string_literal: true

require "spec_helper"

describe "Conference registrations" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }
  let(:conference) { create(:conference, :published, organization:) }
  let(:registration_type) { create(:registration_type, conference:) }
  let(:conference_path) { decidim_conferences.conference_path(conference) }
  let(:registration_path) do
    decidim_conferences.conference_registration_type_conference_registration_path(conference_slug: conference.slug, registration_type_id: registration_type.id)
  end

  before do
    host! organization.host
    login_as user, scope: :user
  end

  describe "POST create" do
    context "when the conference has no available slots" do
      let(:conference) { create(:conference, :published, organization:, available_slots: 1) }

      before do
        create(:conference_registration, conference:, registration_type:, user: create(:user, :confirmed, organization:))
      end

      it "shows the alert on the conference page" do
        post(registration_path)

        expect(response).to redirect_to(conference_path)
        follow_redirect!

        expect(response.body).to include(I18n.t("conference_registrations.create.invalid", scope: "decidim.conferences"))
      end
    end
  end

  describe "DELETE destroy" do
    context "when the user has no registration" do
      it "shows the alert on the conference page" do
        delete(registration_path)

        expect(response).to redirect_to(conference_path)
        follow_redirect!

        expect(response.body).to include(I18n.t("conference_registrations.destroy.invalid", scope: "decidim.conferences"))
      end
    end
  end

  describe "GET decline_invitation" do
    context "when the invitation cannot be declined" do
      before do
        create(:conference_invite, conference:, registration_type:, user:)
        stub_command_broadcast(Decidim::Conferences::DeclineInvitation, :invalid)
      end

      it "shows the alert on the conference page" do
        get(decidim_conferences.decline_invitation_conference_registration_type_conference_registration_path(conference_slug: conference.slug, registration_type_id: registration_type.id))

        expect(response).to redirect_to(conference_path)
        follow_redirect!

        expect(response.body).to include(I18n.t("conference_registrations.decline_invitation.invalid", scope: "decidim.conferences"))
      end
    end
  end
end
