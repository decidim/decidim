# frozen_string_literal: true

require "spec_helper"

describe "User creates meeting" do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let(:organization) { create(:organization, available_authorizations: %w(dummy_authorization_handler another_dummy_authorization_handler)) }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
  let(:current_component) do
    create(:meeting_component, participatory_space: participatory_process, settings: { taxonomy_filters: taxonomy_filter_ids })
  end
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
  let(:root_taxonomy) { create(:taxonomy, organization:) }
  let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
  let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
  let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
  let(:taxonomy_filter_ids) { [taxonomy_filter.id] }

  before do
    switch_to_host(organization.host)
  end

  context "when creating a new meeting", :serves_geocoding_autocomplete do
    let(:user) { create(:user, :confirmed, organization:) }

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
        let(:meeting_title) { "An impressively original meeting title" }
        let(:meeting_description) { Faker::Lorem.sentence(word_count: 5) }
        let(:meeting_location) { Faker::Lorem.sentence(word_count: 3) }
        let(:meeting_location_hints) { Faker::Lorem.sentence(word_count: 3) }
        let(:meeting_address) { "Some address" }
        let(:latitude) { 40.1234 }
        let(:longitude) { 2.1234 }
        let(:base_date) { Time.new.utc }
        let(:meeting_start_date) { base_date.strftime("%d/%m/%Y") }
        let(:start_month) { base_date.strftime("%b") }
        let(:start_day) { base_date.day }
        let(:meeting_start_time) { base_date.strftime("%H:%M") }
        let(:end_date) { (base_date + 2.days) + 1.month }
        let(:meeting_end_date) { end_date.strftime("%d/%m/%Y") }
        let(:end_month) { end_date.strftime("%b") }
        let(:end_day) { end_date.day }
        let(:meeting_end_time) { (base_date + 4.hours).strftime("%H:%M") }
        let(:meeting_available_slots) { 30 }
        let(:meeting_registration_terms) { "These are the registration terms for this meeting" }
        let(:online_meeting_url) { "http://decidim.org" }

        before do
          component.update!(settings: { creation_enabled_for_participants: true, taxonomy_filters: taxonomy_filter_ids })
        end

        context "and rich_editor_public_view component setting is enabled" do
          before do
            organization.update(rich_text_editor_in_public_views: true)
            visit_component
            click_on "New meeting"
          end

          it_behaves_like "having a rich text editor", "new_meeting", "basic"
        end

        it "creates a new meeting", :slow do
          stub_geocoding(meeting_address, [latitude, longitude])
          stub_geocoding_coordinates([latitude, longitude])
          visit_component

          click_on "New meeting"

          within ".new_meeting" do
            fill_in :meeting_title, with: meeting_title
            fill_in :meeting_description, with: meeting_description
            select "In person", from: :meeting_type_of_meeting
            fill_in :meeting_location, with: meeting_location
            fill_in :meeting_location_hints, with: meeting_location_hints
            fill_in_geocoding :meeting_address, with: meeting_address
            fill_in_datepicker :meeting_start_time_date, with: meeting_start_date
            fill_in_timepicker :meeting_start_time_time, with: meeting_start_time
            fill_in_datepicker :meeting_end_time_date, with: meeting_end_date
            fill_in_timepicker :meeting_end_time_time, with: meeting_end_time
            select "Registration disabled", from: :meeting_registration_type
            select decidim_sanitize_translated(taxonomy.name), from: "taxonomies-#{taxonomy_filter.id}"

            find("*[type=submit]").click
          end

          expect(page).to have_content("successfully")
          expect(page).to have_content(meeting_title)
          expect(page).to have_content(meeting_description)
          expect(page).to have_content(decidim_sanitize_translated(taxonomy.name))
          expect(page).to have_content(meeting_address)
          expect(page).to have_content("#{start_month.upcase}\n-\n#{end_month.upcase}")
          expect(page).to have_content(start_day)
          expect(page).to have_content(end_day)
          expect(page).to have_content(meeting_start_time)
          expect(page).to have_content(meeting_end_time)
          expect(page).to have_css("[data-author]", text: user.name)

          visit decidim.last_activities_path
          expect(page).to have_content("New meeting: #{meeting_title}")

          within "#filters" do
            find("a", class: "filter", text: "Meeting", match: :first).click
          end

          expect(page).to have_content("New meeting: #{meeting_title}")
        end

        context "when using the front-end geocoder" do
          it_behaves_like(
            "a record with front-end geocoding address field",
            Decidim::Meetings::Meeting,
            within_selector: ".new_meeting",
            address_field: :meeting_address
          ) do
            before do
              stub_geocoding_coordinates([3.345, 4.456])
              # Prepare the view for submission (other than the address field)
              visit_component

              click_on "New meeting"

              within ".new_meeting" do
                fill_in :meeting_title, with: meeting_title
                fill_in :meeting_description, with: meeting_description
                select "In person", from: :meeting_type_of_meeting
                fill_in :meeting_location, with: meeting_location
                fill_in :meeting_location_hints, with: meeting_location_hints
                fill_in_datepicker :meeting_start_time_date, with: meeting_start_date
                fill_in_timepicker :meeting_start_time_time, with: meeting_start_time
                fill_in_datepicker :meeting_end_time_date, with: meeting_end_date
                fill_in_timepicker :meeting_end_time_time, with: meeting_end_time
                select "Registration disabled", from: :meeting_registration_type
              end
            end
          end
        end

        context "when the user is not authorized" do
          context "when there is only an authorization required" do
            before do
              permissions = {
                create: {
                  authorization_handlers: {
                    "dummy_authorization_handler" => { "options" => {} }
                  }
                }
              }

              component.update!(permissions:)
            end

            it "redirects to the authorization form" do
              visit_component
              click_on "New meeting"

              expect(page).to have_content("We need to verify your identity")
              expect(page).to have_content("Verify with Example authorization")
            end
          end

          context "when there are more than one authorization required" do
            before do
              permissions = {
                create: {
                  authorization_handlers: {
                    "dummy_authorization_handler" => { "options" => {} },
                    "another_dummy_authorization_handler" => { "options" => {} }
                  }
                }
              }

              component.update!(permissions:)
            end

            it "redirects to pending onboarding authorizations page" do
              visit_component
              click_on "New meeting"

              expect(page).to have_content("You are almost ready to create")
              expect(page).to have_css("a[data-verification]", count: 2)
            end
          end
        end

        it "lets the user choose the registrations type" do
          visit_component

          click_on "New meeting"

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

          click_on "New meeting"

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
