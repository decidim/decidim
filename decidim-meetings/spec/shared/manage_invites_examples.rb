# frozen_string_literal: true

def visit_meeting_invites_page
  within find("tr", text: translated(meeting.title)) do
    page.click_link "Registrations"
  end

  page.click_link "Invites"
end

def fill_in_meeting_registration_invite(name:, email:)
  within "form.new_meeting_registration_invite" do
    fill_in :meeting_registration_invite_name, with: name
    fill_in :meeting_registration_invite_email, with: email

    click_button "Invite"
  end

  expect(page).to have_content("successfully")
end

shared_examples "manage invites" do
  describe "inviting an attendee" do
    context "when registrations are not enabled" do
      it "cannot invite people to join a meeting" do
        visit_meeting_invites_page

        expect(page).to have_content("registrations are disabled")

        within "form.new_meeting_registration_invite" do
          expect(page).to have_selector("button[disabled]", text: "Invite")
        end
      end
    end

    context "when registrations are enabled" do
      let!(:meeting) { create :meeting, scope: scope, component: current_component, registrations_enabled: true }

      context "when inviting a unregistered user" do
        it "the invited user sign up into the application and joins the meeting" do
          visit_meeting_invites_page

          perform_enqueued_jobs do
            fill_in_meeting_registration_invite name: "Foo", email: "foo@example.org"
          end

          within "#meeting-invites table" do
            expect(page).to have_content("Foo")
            expect(page).to have_content("foo@example.org")
          end

          logout :user

          visit last_email_link

          within "form.new_user" do
            fill_in :user_nickname, with: "caballo_loco"
            fill_in :user_password, with: "123456"
            fill_in :user_password_confirmation, with: "123456"
            check :user_tos_agreement
            find("*[type=submit]").click
          end

          expect(page).to have_content "successfully"

          within ".card.extra" do
            expect(page).to have_css(".button", text: "GOING")
          end
        end

        it "the invited user sign up into the application and declines the invitation" do
          visit_meeting_invites_page

          perform_enqueued_jobs do
            fill_in_meeting_registration_invite name: "Foo", email: "foo@example.org"
          end

          within "#meeting-invites table" do
            expect(page).to have_content("Foo")
            expect(page).to have_content("foo@example.org")
          end

          logout :user

          visit last_email_first_link

          within "form.new_user" do
            fill_in :user_nickname, with: "caballo_loco"
            fill_in :user_password, with: "123456"
            fill_in :user_password_confirmation, with: "123456"
            check :user_tos_agreement
            find("*[type=submit]").click
          end

          expect(page).to have_content "declined the invitation successfully"

          within ".card.extra" do
            expect(page).to have_css(".button", text: "JOIN MEETING")
          end
        end
      end

      context "when inviting a registered user" do
        let!(:registered_user) { create(:user, :confirmed, organization: organization) }

        it "the invited user joins the meeting" do
          visit_meeting_invites_page

          perform_enqueued_jobs do
            fill_in_meeting_registration_invite name: registered_user.name, email: registered_user.email
          end

          within "#meeting-invites table" do
            expect(page).to have_content(registered_user.name)
            expect(page).to have_content(registered_user.email)
          end

          relogin_as registered_user

          visit last_email_link

          within ".card.extra" do
            expect(page).to have_css(".button", text: "GOING")
          end
        end

        it "the invited user declines the invitation" do
          visit_meeting_invites_page

          perform_enqueued_jobs do
            fill_in_meeting_registration_invite name: registered_user.name, email: registered_user.email
          end

          within "#meeting-invites table" do
            expect(page).to have_content(registered_user.name)
            expect(page).to have_content(registered_user.email)
          end

          relogin_as registered_user

          visit last_email_first_link

          within ".card.extra" do
            expect(page).to have_css(".button", text: "JOIN MEETING")
          end
        end
      end
    end
  end

  describe "listing the invites" do
    let!(:invites) { create_list(:invite, 2, meeting: meeting) }

    it "shows all invites" do
      visit_meeting_invites_page

      within "#meeting-invites table tbody" do
        expect(page).to have_css("tr", count: 2)
      end
    end

    context "when filtering" do
      it "allows searching by text" do
        visit_meeting_invites_page

        within ".filters__search" do
          fill_in :q, with: invites.first.user.email
          find(".icon--magnifying-glass").click
        end

        within "#meeting-invites table tbody" do
          expect(page).to have_css("tr", count: 1)
          expect(page).to have_content(invites.first.user.name)
          expect(page).not_to have_content(invites.last.user.name)
        end
      end

      it "allows filtering by status" do
        accepted_invite = create(:invite, :accepted, meeting: meeting)
        rejected_invite = create(:invite, :rejected, meeting: meeting)
        visit_meeting_invites_page

        within ".filters" do
          find("ul.dropdown > li > a").click # Open the dropdown-menu
          find_link("Accepted", visible: false).click
        end

        within "#meeting-invites table tbody" do
          expect(page).to have_css("tr", count: 1)
          expect(page).to have_content(accepted_invite.user.name)
          expect(page).not_to have_content(rejected_invite.user.name)
        end

        within ".filters" do
          find("ul.dropdown > li > a").click # Open the dropdown-menu
          find_link("Rejected", visible: false).click
        end

        within "#meeting-invites table tbody" do
          expect(page).to have_css("tr", count: 1)
          expect(page).to have_content(rejected_invite.user.name)
          expect(page).not_to have_content(accepted_invite.user.name)
        end
      end
    end
  end
end
