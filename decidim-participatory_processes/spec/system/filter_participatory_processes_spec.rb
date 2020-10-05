# frozen_string_literal: true

require "spec_helper"

describe "Filter Participatory Processes", type: :system do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
  end

  shared_examples "listing all processes" do
    it "lists all processes ordered by start_date (closest to current_date)" do
      within "#processes-grid h3" do
        expect(page).to have_content("6 PROCESSES")
      end

      within "#processes-grid" do
        expect(titles[0].text).to eq("Started today")
        expect(titles[1].text).to eq("Started 1 day ago")
        expect(titles[2].text).to eq("Starts 1 week from now")
        expect(titles[3].text).to eq("Started 2 weeks ago")
        expect(titles[4].text).to eq("Started 3 weeks ago")
        expect(titles[5].text).to eq("Starts 1 year from now")
      end
    end
  end

  context "when filtering processes by date" do
    let!(:active_process) { create :participatory_process, title: { en: "Started today" }, start_date: Date.current, organization: organization }
    let!(:active_process_2) { create :participatory_process, title: { en: "Started 1 day ago" }, start_date: 1.day.ago, organization: organization }
    let!(:past_process) { create :participatory_process, :past, title: { en: "Ended 1 week ago" }, organization: organization }
    let!(:past_process_2) { create :participatory_process, :past, title: { en: "Ended 1 month ago" }, end_date: 1.month.ago, organization: organization }
    let!(:upcoming_process) { create :participatory_process, :upcoming, title: { en: "Starts 1 week from now" }, organization: organization }
    let!(:upcoming_process_2) { create :participatory_process, :upcoming, title: { en: "Starts 1 year from now" }, start_date: 1.year.from_now, organization: organization }
    let(:titles) { page.all(".card__title") }

    before do
      visit decidim_participatory_processes.participatory_processes_path
    end

    context "and choosing 'active' processes" do
      it "lists the active processes ordered by start_date (descendingly)" do
        within "#processes-grid h3" do
          expect(page).to have_content("2 ACTIVE PROCESSES")
        end

        within "#processes-grid" do
          expect(titles.first.text).to eq("Started today")
          expect(titles.last.text).to eq("Started 1 day ago")
        end
      end
    end

    context "and choosing 'past' processes" do
      before do
        within ".order-by__tabs" do
          click_link "Past"
        end
      end

      it "lists the past processes ordered by end_date (descendingly)" do
        within "#processes-grid h3" do
          expect(page).to have_content("2 PAST PROCESSES")
        end

        within "#processes-grid" do
          expect(titles.first.text).to eq("Ended 1 week ago")
          expect(titles.last.text).to eq("Ended 1 month ago")
        end
      end
    end

    context "and choosing 'upcoming' processes" do
      before do
        within ".order-by__tabs" do
          click_link "Upcoming"
        end
      end

      it "lists the upcoming processes ordered by start_date (ascendingly)" do
        within "#processes-grid h3" do
          expect(page).to have_content("2")
        end

        within "#processes-grid" do
          expect(titles.first.text).to eq("Starts 1 week from now")
          expect(titles.last.text).to eq("Starts 1 year from now")
        end
      end
    end

    context "and choosing 'all' processes" do
      let(:time_zone) { Time.zone } # UTC

      before do
        past_process.update(title: { en: "Started 2 weeks ago" })
        past_process_2.update(title: { en: "Started 3 weeks ago" }, start_date: 3.weeks.ago)
        allow(Time).to receive(:zone).and_return(time_zone)
        within ".order-by__tabs" do
          click_link "All"
        end
      end

      it_behaves_like "listing all processes"

      context "when the configured time_zone is not UTC" do
        let(:time_zone) { ActiveSupport::TimeZone.new("Madrid") }

        it_behaves_like "listing all processes"
      end
    end
  end

  context "when filtering processes by scope" do
    let!(:scope) { create :scope, organization: organization }
    let!(:process_with_scope) { create(:participatory_process, scope: scope, organization: organization) }
    let!(:process_without_scope) { create(:participatory_process, organization: organization) }

    context "and choosing a scope" do
      before do
        visit decidim_participatory_processes.participatory_processes_path(filter: { scope_id: scope.id })
      end

      it "lists all processes belonging to that scope" do
        expect(page).to have_content(translated(process_with_scope.title))
        expect(page).not_to have_content(translated(process_without_scope.title))
      end
    end
  end

  context "when filtering processes by area" do
    let!(:area) { create :area, organization: organization }
    let!(:process_with_area) { create(:participatory_process, area: area, organization: organization) }
    let!(:process_without_area) { create(:participatory_process, organization: organization) }

    before do
      visit decidim_participatory_processes.participatory_processes_path
    end

    context "and choosing an area" do
      before do
        select translated(area.name), from: "filter[area_id]"
      end

      it "lists all processes belonging to that area" do
        expect(page).to have_content(translated(process_with_area.title))
        expect(page).not_to have_content(translated(process_without_area.title))
      end
    end
  end
end
