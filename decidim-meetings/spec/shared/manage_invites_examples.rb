# frozen_string_literal: true

def visit_meeting_invites_page
  within "tr", text: translated(meeting.title) do
    find("button[data-component='dropdown']").click
    click_on "Registrations"
  end

  click_on "Invitations"
end

def invite_unregistered_user(name:, email:)
  visit_meeting_invites_page

  within "form.new_meeting_registration_invite" do
    choose "Non existing participant", name: "meeting_registration_invite[existing_user]"
    fill_in :meeting_registration_invite_name, with: name
    fill_in :meeting_registration_invite_email, with: email

    perform_enqueued_jobs do
      click_on "Invite"
    end
  end

  expect(page).to have_content("successfully")

  within "#meeting-invites table" do
    expect(page).to have_content(name)
    expect(page).to have_content(email)
  end
end

def invite_existing_user(user)
  visit_meeting_invites_page

  within "form.new_meeting_registration_invite" do
    choose "Existing participant", name: "meeting_registration_invite[existing_user]"
    autocomplete_select "#{user.name} (@#{user.nickname})", from: :user_id

    perform_enqueued_jobs do
      click_on "Invite"
    end
  end

  expect(page).to have_content("successfully")

  within "#meeting-invites table" do
    expect(page).to have_content(registered_user.name)
    expect(page).to have_content(registered_user.email)
  end
end

shared_examples "manage invites" do
  before do
    stub_geocoding_coordinates([meeting.latitude, meeting.longitude])
  end

  describe "inviting an attendee" do
    context "when registrations are not enabled" do
      it "cannot invite people to join a meeting" do
        visit_meeting_invites_page

        expect(page).to have_content("registrations are disabled")

        within "form.new_meeting_registration_invite" do
          expect(page).to have_css("button[disabled]", text: "Invite")
        end
      end
    end

    context "when registrations are enabled" do
      let!(:meeting) { create(:meeting, :published, scope:, component: current_component, registrations_enabled: true) }

      context "when inviting a unregistered user" do
        it "the invited user sign up into the application and joins the meeting" do
          invite_unregistered_user name: "Foo", email: "foo@example.org"

          logout :user
          perform_enqueued_jobs

          visit last_email_link

          within "form.new_user" do
            fill_in :invitation_user_nickname, with: "caballo_loco"
            fill_in :invitation_user_password, with: "decidim123456789"
            check :invitation_user_tos_agreement
            find("*[type=submit]").click
          end

          expect(page).to have_content "successfully"
          expect(page).to have_css(".button", text: "Cancel your registration")
        end

        it "the invited user sign up into the application and declines the invitation" do
          invite_unregistered_user name: "Foo", email: "foo@example.org"

          logout :user
          perform_enqueued_jobs

          visit last_email_first_link

          within "form.new_user" do
            fill_in :invitation_user_nickname, with: "caballo_loco"
            fill_in :invitation_user_password, with: "decidim123456789"
            check :invitation_user_tos_agreement
            find("*[type=submit]").click
          end

          expect(page).to have_content "declined the invitation successfully"
          expect(page).to have_css(".button", text: "Register")
        end
      end

      context "when inviting a registered user" do
        let!(:registered_user) { create(:user, :confirmed, organization:) }

        it "the invited user joins the meeting" do
          invite_existing_user registered_user

          relogin_as registered_user
          perform_enqueued_jobs

          visit last_email_link

          expect(page).to have_css(".button", text: "Cancel your registration")
        end

        it "the invited user declines the invitation" do
          invite_existing_user registered_user

          relogin_as registered_user
          perform_enqueued_jobs

          visit last_email_first_link

          expect(page).to have_css(".button", text: "Register")
        end
      end

      context "when inviting a registered user as if not registered" do
        let!(:registered_user) { create(:user, :confirmed, organization:) }

        it "the invited user joins the meeting" do
          invite_unregistered_user name: registered_user.name, email: registered_user.email

          relogin_as registered_user
          perform_enqueued_jobs

          visit last_email_link

          expect(page).to have_css(".button", text: "Cancel your registration")
        end

        it "the invited user declines the invitation" do
          invite_unregistered_user name: registered_user.name, email: registered_user.email

          relogin_as registered_user

          perform_enqueued_jobs
          visit last_email_first_link

          expect(page).to have_css(".button", text: "Register")
        end
      end
    end
  end

  describe "listing the invites" do
    let!(:invites) { create_list(:invite, 2, meeting:) }

    it "shows all invites" do
      visit_meeting_invites_page

      within "#meeting-invites table tbody" do
        expect(page).to have_css("tr", count: 2)
      end
    end

    context "when filtering" do
      include_context "with filterable context"

      it "allows searching by text" do
        visit_meeting_invites_page

        within ".filters__section" do
          fill_in :q_user_name_or_user_email_cont, with: invites.first.user.email
          click_on(class: "text-secondary")
        end

        within "#meeting-invites table tbody" do
          expect(page).to have_css("tr", count: 1)
          expect(page).to have_content(invites.first.user.name)
          expect(page).to have_no_content(invites.last.user.name)
        end
      end

      it "allows filtering by status" do
        accepted_invite = create(:invite, :accepted, meeting:)
        rejected_invite = create(:invite, :rejected, meeting:)

        visit_meeting_invites_page

        apply_filter("Accepted", "Accepted")

        within "#meeting-invites table tbody" do
          expect(page).to have_css("tr", count: 1)
          expect(page).to have_content(accepted_invite.user.name)
          expect(page).to have_no_content(rejected_invite.user.name)
        end

        remove_applied_filter("Accepted")
        apply_filter("Rejected", "Rejected")

        within "#meeting-invites table tbody" do
          expect(page).to have_css("tr", count: 1)
          expect(page).to have_content(rejected_invite.user.name)
          expect(page).to have_no_content(accepted_invite.user.name)
        end
      end
    end
  end
end
