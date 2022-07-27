# frozen_string_literal: true

require "spec_helper"

describe "Upcoming meeting for card view hook", type: :system do
  include_context "with a component" do
    let(:participatory_space) { assembly }
  end

  let(:assembly) { create :assembly, organization: }
  let(:manifest_name) { "meetings" }
  let!(:past_meeting) do
    create(:meeting, :published, :past, component:)
  end

  context "when there are only past meetings" do
    it "doesn't show any meeting" do
      visit decidim_assemblies.assemblies_path

      within "#assembly_#{assembly.id}" do
        expect(page).to have_no_selector(".card__icondata")
      end
    end
  end

  context "when there are some upcoming meetings" do
    let(:start_time) { Time.zone.local(2099, 5, 31, 12, 34) }
    let!(:upcoming_meeting1) do
      create(:meeting, :published, :upcoming, start_time:, end_time: start_time + 1.hour, component:)
    end
    let!(:upcoming_meeting2) do
      create(:meeting, :published, :upcoming, start_time: start_time + 1.year, end_time: start_time + 1.year + 1.hour, component:)
    end

    it "shows the next upcoming meeting" do
      visit decidim_assemblies.assemblies_path

      within "#assembly_#{assembly.id}" do
        expect(page).to have_selector(".card__icondata")

        within ".card__icondata" do
          expect(page).to have_text("31 MAY 2099")
          expect(page).to have_text("12:34")
          expect(page).to have_text("13:34")
        end
      end
    end
  end
end
