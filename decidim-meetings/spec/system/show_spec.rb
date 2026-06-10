# frozen_string_literal: true

require "spec_helper"

describe "show" do
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
      expect(page).to have_text meeting.title[I18n.locale.to_s]
    end

    it_behaves_like "a 404 page" do
      let(:target_path) do
        decidim_participatory_process_meetings.meeting_path(
          participatory_process_slug: component.participatory_space.slug,
          component_id: component.id,
          id: 999_999
        )
      end
    end

    it "shows correct the time zone" do
      expect(page).to have_text("UTC")
    end

    context "when the organization has a different timezone" do
      before do
        organization.update!(time_zone: "Hawaii")

        visit resource_locator(meeting).path
      end

      it "shows the correct time zone" do
        expect(page).to have_text("HST")
      end
    end

    context "when participant is deleted" do
      let(:user) { create(:user, :deleted, organization:) }
      let!(:meeting) { create(:meeting, :published, author: user.reload, component:) }

      it "successfully shows the page" do
        expect(page).to have_text("Deleted participant")
      end
    end

    context "when meeting has many public participants" do
      let!(:users) { create_list(:user, 15, organization:) }
      let(:show_more_text) { I18n.t("show_more", scope: "decidim.meetings.public_participants_list") }
      let(:show_less_text) { I18n.t("show_less", scope: "decidim.meetings.public_participants_list") }

      before do
        users.each do |user|
          create(:registration, meeting:, user:, public_participation: true)
        end
      end

      context "with a desktop" do
        before do
          visit resource_locator(meeting).path
        end

        it "shows a limited list with a toggle" do
          within "#panel-participants" do
            expect(page).to have_css("[data-participants-item]", count: 12)
            expect(page).to have_css("[data-participants-item]", count: 15, visible: :all)
          end
        end

        it "expands and collapses the list" do
          within "#panel-participants" do
            expect(page).to have_css("[data-participants-item]", count: 12)
            expect(page).to have_text(show_more_text)
            click_toggle_button
            expect(page).to have_css("[data-participants-item]", count: 15)
            expect(page).to have_text(show_less_text)
            click_toggle_button
            expect(page).to have_css("[data-participants-item]", count: 12)
            expect(page).to have_text(show_more_text)
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
            expect(page).to have_css("[data-participants-item]", count: 8)
            expect(page).to have_css("[data-participants-item]", count: 15, visible: :all)
          end
        end

        it "expands and collapses the list" do
          within "#panel-participants" do
            expect(page).to have_css("[data-participants-item]", count: 8)
            expect(page).to have_text(show_more_text)
            click_toggle_button
            expect(page).to have_css("[data-participants-item]", count: 15)
            expect(page).to have_text(show_less_text)
            click_toggle_button
            expect(page).to have_css("[data-participants-item]", count: 8)
            expect(page).to have_text(show_more_text)
          end
        end
      end
    end
  end

  private

  def click_toggle_button
    # Seems like the :iphone driver does not play nicely with a
    # click_on("Show more") as the button has an icon inside
    # as a workaround, we do this equivalent that works correctly with this driver
    find("[data-participants-toggle]", visible: :all).send_keys(:enter)
  end
end
