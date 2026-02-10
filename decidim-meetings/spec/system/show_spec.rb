# frozen_string_literal: true

require "spec_helper"

describe "show", js: true do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let!(:meeting) { create(:meeting, :published, component:) }

  before do
    stub_geocoding_coordinates([meeting.latitude, meeting.longitude])
    visit_component
    click_on meeting.title[I18n.locale.to_s]
  end

  context "when shows the meeting component" do
    it "shows the meeting title" do
      expect(page).to have_content meeting.title[I18n.locale.to_s]
    end

    it_behaves_like "a 404 page" do
      let(:target_path) do
        decidim_participatory_process_meetings.meeting_path(
          participatory_process_slug: component.participatory_space.slug,
          component_id: component.id,
          id: 999_999,
          locale: I18n.locale
        )
      end
    end

    it "shows correct the time zone" do
      expect(page).to have_content("UTC")
    end

    context "when the organization has a different timezone" do
      before do
        organization.update!(time_zone: "Hawaii")

        visit resource_locator(meeting).path
      end

      it "shows the correct time zone" do
        expect(page).to have_content("HST")
      end
    end

    context "when participant is deleted" do
      let(:user) { create(:user, :deleted, organization:) }
      let!(:meeting) { create(:meeting, :published, author: user.reload, component:) }

      it "successfully shows the page" do
        expect(page).to have_content("Deleted participant")
      end
    end

    context "when meeting has many public participants" do
      let!(:users) { create_list(:user, 15, organization:) }

      before do
        users.each do |user|
          create(:registration, meeting:, user:, public_participation: true)
        end

        visit resource_locator(meeting).path
      end

      it "shows a limited list with a toggle" do
        within "#panel-participants" do
          expect(page).to have_css("[data-participants-item]", count: 15, visible: :all)
          expect(page).to have_text("Show more")
        end
      end

      it "expands and collapses the list" do
        within "#panel-participants" do
          toggle = find("[data-participants-toggle]", visible: :all)
          expect(page).to have_css(".meeting__public-participants-item:not(.hidden)", count: 12)
          toggle.click
          expect(page).to have_css(".meeting__public-participants-item:not(.hidden)", count: 15)
          expect(toggle).to have_text("Show less")
          toggle.click
          expect(page).to have_css(".meeting__public-participants-item:not(.hidden)", count: 12)
          expect(toggle).to have_text("Show more")
        end
      end

      context "with a desktop" do
        it "limits visible participants by viewport" do
          within "#panel-participants" do
            expect(page).to have_css(".meeting__public-participants-item:not(.hidden)", count: 12)
          end
        end
      end

      context "with a mobile device" do
        before do
          driven_by(:iphone)
          visit resource_locator(meeting).path
        end

        it "limits visible participants by viewport" do
          within "#panel-participants" do
            expect(page).to have_css(".meeting__public-participants-item:not(.hidden)", count: 8)
          end
        end

        it "expands and collapses the list" do
          within "#panel-participants" do
            toggle = find("[data-participants-toggle]", visible: :all)
            expect(page).to have_css(".meeting__public-participants-item:not(.hidden)", count: 8)
            toggle.click
            expect(page).to have_css(".meeting__public-participants-item:not(.hidden)", count: 15)
            expect(toggle).to have_text("Show less")
            toggle.click
            expect(page).to have_css(".meeting__public-participants-item:not(.hidden)", count: 8)
            expect(toggle).to have_text("Show more")
          end
        end
      end
    end
  end
end
