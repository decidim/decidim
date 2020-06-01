# frozen_string_literal: true

require "spec_helper"

describe "User creates meeting", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization: organization) }
  let(:current_component) { create :meeting_component, participatory_space: participatory_process }
  let(:start_time) { 1.day.from_now }
  let(:meetings_count) { 5 }
  let!(:meetings) do
    create_list(
      :meeting,
      meetings_count,
      component: current_component,
      start_time: 1.day.from_now,
      end_time: start_time + 4.hours
    )
  end

  before do
    switch_to_host(organization.host)
  end

  context "when creating a new meeting" do
    let(:user) { create :user, :confirmed, organization: organization }
    let!(:category) { create :category, participatory_space: participatory_space }

    context "when the user is logged in" do
      before do
        login_as user, scope: :user
      end

      context "with creation enabled" do
        let!(:component) do
          create(:meeting_component,
                 # :with_creation_enabled,
                 participatory_space: participatory_process)
        end
        let(:meeting_title) { Faker::Lorem.sentence(1) }
        let(:meeting_description) { Faker::Lorem.sentence(2) }
        let(:meeting_location) { Faker::Lorem.sentence(3) }
        let(:meeting_location_hints) { Faker::Lorem.sentence(3) }
        let(:meeting_address) { "Carrer Pare Llaurador 113, baixos, 08224 Terrassa" }
        let(:latitude) { 40.1234 }
        let(:longitude) { 2.1234 }
        let!(:meeting_start_time) { Time.current + 2.days }
        let(:meeting_end_time) { meeting_start_time + 4.hours }
        let(:meeting_scope) { create :scope, organization: organization }

        context "and rich_editor_public_view component setting is enabled" do
          before do
            organization.update(rich_text_editor_in_public_views: true)
            visit_component
            click_link "New Meeting"
          end

          it_behaves_like "having a rich text editor", "new_meeting", "basic"
        end

        it "creates a new meeting", :slow do
          stub_geocoding(meeting_address, [latitude, longitude])

          visit_component

          click_link "New Meeting"

          within ".new_meeting" do
            fill_in :meeting_title, with: meeting_title
            fill_in :meeting_description, with: meeting_description
            fill_in :meeting_location, with: meeting_location
            fill_in :meeting_location_hints, with: meeting_location_hints
            fill_in :meeting_address, with: meeting_address
            fill_in :meeting_start_time, with: meeting_start_time.strftime("%Y/%m/%d %H:%M")
            fill_in :meeting_end_time, with: meeting_end_time.strftime("%Y/%m/%d %H:%M")
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
          expect(page).to have_content(meeting_start_time.strftime("%H:%M"))
          expect(page).to have_content(meeting_end_time.strftime("%H:%M"))
          expect(page).to have_selector(".author-data", text: user.name)
        end

        context "when creating as a user group" do
          let!(:user_group) { create :user_group, :verified, organization: organization, users: [user] }

          it "creates a new meeting", :slow do
            visit_component

            click_link "New Meeting"

            within ".new_meeting" do
              fill_in :meeting_title, with: meeting_title
              fill_in :meeting_description, with: meeting_description
              fill_in :meeting_location, with: meeting_location
              fill_in :meeting_location_hints, with: meeting_location_hints
              fill_in :meeting_address, with: meeting_address
              fill_in :meeting_start_time, with: meeting_start_time.strftime("%Y/%m/%d %H:%M")
              fill_in :meeting_end_time, with: meeting_end_time.strftime("%Y/%m/%d %H:%M")
              select translated(category.name), from: :meeting_decidim_category_id
              scope_pick select_data_picker(:meeting_decidim_scope_id), meeting_scope
              select user_group.name, from: :meeting_organizer_gid

              find("*[type=submit]").click
            end

            expect(page).to have_content("successfully")
            expect(page).to have_content(meeting_title)
            expect(page).to have_content(meeting_description)
            expect(page).to have_content(translated(category.name))
            expect(page).to have_content(translated(meeting_scope.name))
            expect(page).to have_content(meeting_address)
            expect(page).to have_content(meeting_start_time.strftime("%H:%M"))
            expect(page).to have_content(meeting_end_time.strftime("%H:%M"))
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
            expect(page).to have_content("Authorization required")
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
