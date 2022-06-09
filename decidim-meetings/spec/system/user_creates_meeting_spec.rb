# frozen_string_literal: true

require "spec_helper"

describe "User creates meeting", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let(:organization) { create(:organization, available_authorizations: %w(dummy_authorization_handler)) }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization: organization) }
  let(:current_component) { create :meeting_component, participatory_space: participatory_process }
  let(:start_time) { 1.day.from_now }
  let(:meetings_count) { 5 }
  let!(:meetings) do
    create_list(
      :meeting,
      meetings_count,
      :published,
      component: current_component,
      start_time: 1.day.from_now,
      end_time: start_time + 4.hours
    )
  end

  before do
    switch_to_host(organization.host)
  end

  context "when creating a new meeting", :serves_geocoding_autocomplete do
    let(:user) { create :user, :confirmed, organization: organization }
    let!(:category) { create :category, participatory_space: participatory_space }

    context "when the user is not logged in" do
      it "redirects the user to the sign in page" do
        page.visit Decidim::EngineRouter.main_proxy(component).new_meeting_path
        expect(page).to have_current_path("/users/sign_in")
      end
    end

    context "when the user is logged in" do
      before do
        login_as user, scope: :user
      end

      context "with creation enabled" do
        let!(:component) do
          create(:meeting_component,
                 :with_creation_enabled,
                 participatory_space: participatory_process)
        end
        let(:meeting_title) { Faker::Lorem.sentence(word_count: 1) }
        let(:meeting_description) { Faker::Lorem.sentence(word_count: 2) }
        let(:meeting_location) { Faker::Lorem.sentence(word_count: 3) }
        let(:meeting_location_hints) { Faker::Lorem.sentence(word_count: 3) }
        let(:meeting_address) { "Some address" }
        let(:latitude) { 40.1234 }
        let(:longitude) { 2.1234 }
        let!(:meeting_start_time) { 2.days.from_now }
        let(:meeting_end_time) { meeting_start_time + 4.hours }
        let(:meeting_available_slots) { 30 }
        let(:meeting_registration_terms) { "These are the registration terms for this meeting" }
        let(:online_meeting_url) { "http://decidim.org" }
        let(:meeting_scope) { create :scope, organization: organization }
        let(:datetime_format) { I18n.t("time.formats.decidim_short") }
        let(:time_format) { I18n.t("time.formats.time_of_day") }

        before do
          component.update!(settings: { scopes_enabled: true, scope_id: participatory_process.scope&.id, creation_enabled_for_participants: true })
        end

        context "and rich_editor_public_view component setting is enabled" do
          before do
            organization.update(rich_text_editor_in_public_views: true)
            visit_component
            click_link "New meeting"
          end

          it_behaves_like "having a rich text editor", "new_meeting", "basic"
        end

        it "creates a new meeting", :slow do
          stub_geocoding(meeting_address, [latitude, longitude])

          visit_component

          click_link "New meeting"

          within ".new_meeting" do
            fill_in :meeting_title, with: meeting_title
            fill_in :meeting_description, with: meeting_description
            select "In person", from: :meeting_type_of_meeting
            fill_in :meeting_location, with: meeting_location
            fill_in :meeting_location_hints, with: meeting_location_hints
            fill_in_geocoding :meeting_address, with: meeting_address
            fill_in :meeting_start_time, with: meeting_start_time.strftime(datetime_format)
            fill_in :meeting_end_time, with: meeting_end_time.strftime(datetime_format)
            select "Registration disabled", from: :meeting_registration_type
            select translated(category.name), from: :meeting_decidim_category_id
            scope_pick select_data_picker(:meeting_decidim_scope_id), meeting_scope

            find("*[type=submit]").click
          end

          expect(page).to have_content("successfully")
          expect(page).to have_content(meeting_title)
          expect(page).to have_content(meeting_description)
          expect(page).to have_content(translated(category.name))
          expect(page).to have_content(translated(meeting_scope.name))
          expect(page).to have_content(meeting_address)
          expect(page).to have_content(meeting_start_time.strftime(time_format))
          expect(page).to have_content(meeting_end_time.strftime(time_format))
          expect(page).to have_selector(".author-data", text: user.name)
        end

        context "when using the front-end geocoder" do
          it_behaves_like(
            "a record with front-end geocoding address field",
            Decidim::Meetings::Meeting,
            within_selector: ".new_meeting",
            address_field: :meeting_address
          ) do
            before do
              # Prepare the view for submission (other than the address field)
              visit_component

              click_link "New meeting"

              within ".new_meeting" do
                fill_in :meeting_title, with: meeting_title
                fill_in :meeting_description, with: meeting_description
                select "In person", from: :meeting_type_of_meeting
                fill_in :meeting_location, with: meeting_location
                fill_in :meeting_location_hints, with: meeting_location_hints
                fill_in :meeting_start_time, with: meeting_start_time.strftime(datetime_format)
                fill_in :meeting_end_time, with: meeting_end_time.strftime(datetime_format)
                select "Registration disabled", from: :meeting_registration_type
              end
            end
          end
        end

        context "when creating as a user group" do
          let!(:user_group) { create :user_group, :verified, organization: organization, users: [user] }

          it "creates a new meeting", :slow do
            stub_geocoding(meeting_address, [latitude, longitude])

            visit_component

            click_link "New meeting"

            within ".new_meeting" do
              fill_in :meeting_title, with: meeting_title
              fill_in :meeting_description, with: meeting_description
              select "In person", from: :meeting_type_of_meeting
              fill_in :meeting_location, with: meeting_location
              fill_in :meeting_location_hints, with: meeting_location_hints
              fill_in_geocoding :meeting_address, with: meeting_address
              fill_in :meeting_start_time, with: meeting_start_time.strftime(datetime_format)
              fill_in :meeting_end_time, with: meeting_end_time.strftime(datetime_format)
              select "Registration disabled", from: :meeting_registration_type
              select translated(category.name), from: :meeting_decidim_category_id
              scope_pick select_data_picker(:meeting_decidim_scope_id), meeting_scope
              select user_group.name, from: :meeting_user_group_id

              find("*[type=submit]").click
            end

            expect(page).to have_content("successfully")
            expect(page).to have_content(meeting_title)
            expect(page).to have_content(meeting_description)
            expect(page).to have_content(translated(category.name))
            expect(page).to have_content(translated(meeting_scope.name))
            expect(page).to have_content(meeting_address)
            expect(page).to have_content(meeting_start_time.strftime(time_format))
            expect(page).to have_content(meeting_end_time.strftime(time_format))
            expect(page).not_to have_css(".button", text: "JOIN MEETING")
            expect(page).to have_selector(".author-data", text: user_group.name)
          end

          it "creates a new meeting with registrations on this platform", :slow do
            stub_geocoding(meeting_address, [latitude, longitude])

            visit_component

            click_link "New meeting"

            within ".new_meeting" do
              fill_in :meeting_title, with: meeting_title
              fill_in :meeting_description, with: meeting_description
              select "In person", from: :meeting_type_of_meeting
              fill_in :meeting_location, with: meeting_location
              fill_in :meeting_location_hints, with: meeting_location_hints
              fill_in_geocoding :meeting_address, with: meeting_address
              fill_in :meeting_start_time, with: meeting_start_time.strftime(datetime_format)
              fill_in :meeting_end_time, with: meeting_end_time.strftime(datetime_format)
              select "On this platform", from: :meeting_registration_type
              fill_in :meeting_available_slots, with: meeting_available_slots
              fill_in :meeting_registration_terms, with: meeting_registration_terms
              select translated(category.name), from: :meeting_decidim_category_id
              scope_pick select_data_picker(:meeting_decidim_scope_id), meeting_scope
              select user_group.name, from: :meeting_user_group_id

              find("*[type=submit]").click
            end

            expect(page).to have_content("successfully")
            expect(page).to have_content(meeting_title)
            expect(page).to have_content(meeting_description)
            expect(page).to have_content(translated(category.name))
            expect(page).to have_content(translated(meeting_scope.name))
            expect(page).to have_content(meeting_address)
            expect(page).to have_content(meeting_start_time.strftime(time_format))
            expect(page).to have_content(meeting_end_time.strftime(time_format))
            expect(page).to have_css(".button", text: "JOIN MEETING")
            expect(page).to have_selector(".author-data", text: user_group.name)
          end
        end

        context "when the user isn't authorized" do
          before do
            permissions = {
              create: {
                authorization_handlers: {
                  "dummy_authorization_handler" => { "options" => {} }
                }
              }
            }

            component.update!(permissions: permissions)
          end

          it "shows a modal dialog" do
            visit_component
            click_link "New meeting"
            expect(page).to have_selector("#authorizationModal")
            expect(page).to have_content("Authorization required")
          end
        end

        it "lets the user choose the registrations type" do
          visit_component

          click_link "New meeting"

          within ".new_meeting" do
            select "Registration disabled", from: :meeting_registration_type
            expect(page).to have_no_field("Registration URL")
            expect(page).to have_no_field("Available slots")
            expect(page).to have_no_field("Registration terms")

            select "On a different platform", from: :meeting_registration_type
            expect(page).to have_field("Registration URL")
            expect(page).to have_no_field("Available slots")
            expect(page).to have_no_field("Registration terms")

            select "On this platform", from: :meeting_registration_type
            expect(page).to have_field("Available slots")
            expect(page).to have_no_field("Registration URL")
            expect(page).to have_field("Registration terms")
          end
        end

        it "lets the user choose the meeting type" do
          visit_component

          click_link "New meeting"

          within ".new_meeting" do
            select "In person", from: :meeting_type_of_meeting
            expect(page).to have_field("Address")
            expect(page).to have_field(:meeting_location)
            expect(page).to have_no_field("Online meeting URL")

            select "Online", from: :meeting_type_of_meeting
            expect(page).to have_no_field("Address")
            expect(page).to have_no_field(:meeting_location)
            expect(page).to have_field("Online meeting URL")

            select "Hybrid", from: :meeting_type_of_meeting
            expect(page).to have_field("Address")
            expect(page).to have_field(:meeting_location)
            expect(page).to have_field("Online meeting URL")
          end
        end
      end

      context "when creation is not enabled" do
        it "does not show the creation button" do
          visit_component
          expect(page).to have_no_link("New meeting")
        end
      end
    end
  end
end
