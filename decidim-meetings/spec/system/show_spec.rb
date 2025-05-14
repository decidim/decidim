# frozen_string_literal: true

require "spec_helper"

describe "show" do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let!(:meeting) { create(:meeting, :published, component:) }

  before do
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
          id: 999_999
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
  end
end
