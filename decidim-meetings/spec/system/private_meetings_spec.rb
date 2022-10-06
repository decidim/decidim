# frozen_string_literal: true

require "spec_helper"

describe "Private meetings", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let!(:meeting) { create :meeting, :published, component:, registrations_enabled: true, available_slots: 20 }
  let!(:private_meeting) { create :meeting, :published, component:, private_meeting: true, transparent: true, registrations_enabled: true, available_slots: 20 }

  let!(:other_user) { create :user, :confirmed, organization: }
  let!(:registration) { create :registration, meeting: private_meeting, user: other_user }

  describe "index" do
    context "when there are private meetings" do
      context "and the meeting is transparent" do
        context "and no user is logged in" do
          before do
            switch_to_host(organization.host)
            visit_component
          end

          it "lists all the meetings" do
            within "#meetings" do
              expect(page).to have_content(translated(meeting.title, locale: :en))
              expect(page).to have_content(translated(private_meeting.title, locale: :en))
              expect(page).to have_selector(".card", count: 2)
            end
          end
        end

        context "when user is logged in and has not been invited to meeting" do
          before do
            switch_to_host(organization.host)
            login_as user, scope: :user
            visit_component
          end

          it "lists all meetings that are transparent" do
            within "#meetings" do
              expect(page).to have_content(translated(meeting.title, locale: :en))
              expect(page).to have_content(translated(private_meeting.title, locale: :en))
              expect(page).to have_selector(".card", count: 2)
            end
          end

          it "links to the individual meeting page" do
            click_link(translated(private_meeting.title, locale: :en))

            expect(page).to have_current_path resource_locator(private_meeting).path
            expect(page).to have_content "Private"
            expect(page).to have_content "Transparent"
            expect(page).not_to have_button("JOIN MEETING")
          end
        end
      end

      context "when the meeting is not transparent" do
        let!(:private_meeting) { create :meeting, :published, component:, private_meeting: true, transparent: false, registrations_enabled: true, available_slots: 20 }

        context "and no user is logged in" do
          before do
            switch_to_host(organization.host)
            visit_component
          end

          it "lists only the not private meetings" do
            within "#meetings" do
              expect(page).to have_content(translated(meeting.title, locale: :en))
              expect(page).to have_selector(".card", count: 1)

              expect(page).to have_no_content(translated(private_meeting.title, locale: :en))
            end
          end
        end

        context "when user is logged in and has not been invited to the meeting" do
          before do
            switch_to_host(organization.host)
            login_as user, scope: :user
            visit_component
          end

          it "lists only the not private meetings" do
            within "#meetings" do
              expect(page).to have_content(translated(meeting.title, locale: :en))
              expect(page).to have_selector(".card", count: 1)

              expect(page).to have_no_content(translated(private_meeting.title, locale: :en))
            end
          end
        end

        context "when user is logged in and has been invited to the meeting" do
          before do
            switch_to_host(organization.host)
            login_as other_user, scope: :user
            visit_component
          end

          it "lists private meetings" do
            within "#meetings" do
              expect(page).to have_content(translated(meeting.title, locale: :en))
              expect(page).to have_content(translated(private_meeting.title, locale: :en))
              expect(page).to have_selector(".card", count: 2)
            end
          end

          it "links to the individual meeting page" do
            click_link(translated(private_meeting.title, locale: :en))

            expect(page).to have_current_path resource_locator(private_meeting).path
            expect(page).to have_content "Private"
            expect(page).to have_css(".button", text: "CANCEL YOUR REGISTRATION")
          end
        end
      end
    end
  end

  describe "show" do
    context "when the meeting is private" do
      context "and is not transparent" do
        let!(:private_meeting) { create :meeting, :published, component:, private_meeting: true, transparent: false, registrations_enabled: true, available_slots: 20 }

        before do
          switch_to_host(organization.host)
          login_as user, scope: :user
          visit resource_locator(private_meeting).path
        end

        it "redirects to index page" do
          expect(page).to have_current_path "#{main_component_path(component)}meetings"
          expect(page).to have_content "You are not allowed to view this meeting"
        end
      end
    end
  end
end
