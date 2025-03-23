# frozen_string_literal: true

require "spec_helper"

describe "Filter Participatory Processes" do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
  end

  shared_examples "listing all processes" do
    it "lists all processes ordered by start_date (closest to current_date)" do
      within "#processes-grid h2" do
        expect(page).to have_content("6 processes")
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
    let!(:active_process) { create(:participatory_process, title: { en: "Started today" }, start_date: Date.current, organization:) }
    let!(:active_process2) { create(:participatory_process, title: { en: "Started 1 day ago" }, start_date: 1.day.ago, organization:) }
    let!(:past_process) { create(:participatory_process, :past, title: { en: "Ended 1 week ago" }, organization:) }
    let!(:past_process2) { create(:participatory_process, :past, title: { en: "Ended 1 month ago" }, end_date: 1.month.ago, organization:) }
    let!(:upcoming_process) { create(:participatory_process, :upcoming, title: { en: "Starts 1 week from now" }, organization:) }
    let!(:upcoming_process2) { create(:participatory_process, :upcoming, title: { en: "Starts 1 year from now" }, start_date: 1.year.from_now, organization:) }
    let(:titles) { page.all(".card__grid-text h3") }

    before do
      visit decidim_participatory_processes.participatory_processes_path(locale: I18n.locale)
    end

    context "and choosing 'active' processes" do
      it "lists the active processes ordered by start_date (descendingly)" do
        within "#processes-grid h2" do
          expect(page).to have_content("2 active processes")
        end

        within "#processes-grid" do
          expect(titles.first.text).to eq("Started today")
          expect(titles.last.text).to eq("Started 1 day ago")
        end
      end
    end

    context "and choosing 'past' processes" do
      before do
        within "#panel-dropdown-menu-date" do
          click_filter_item "Past"
        end
      end

      it "lists the past processes ordered by end_date (descendingly)" do
        within "#processes-grid h2" do
          expect(page).to have_content("2 past processes")
        end

        within "#processes-grid" do
          expect(titles.first.text).to eq("Ended 1 week ago")
          expect(titles.last.text).to eq("Ended 1 month ago")
        end
      end
    end

    context "and choosing 'upcoming' processes" do
      before do
        within "#panel-dropdown-menu-date" do
          click_filter_item "Upcoming"
        end
        sleep 2
      end

      it "lists the upcoming processes ordered by start_date (ascendingly)" do
        within "#processes-grid h2" do
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
        past_process2.update(title: { en: "Started 3 weeks ago" }, start_date: 3.weeks.ago)
        allow(Time).to receive(:zone).and_return(time_zone)
        within "#panel-dropdown-menu-date" do
          click_filter_item "All"
        end
      end

      it_behaves_like "listing all processes"

      context "when the configured time_zone is not UTC" do
        let(:time_zone) { ActiveSupport::TimeZone.new("Madrid") }

        it_behaves_like "listing all processes"
      end
    end
  end

  context "when filtering parent participatory processes by taxonomies" do
    let!(:taxonomy) { create(:taxonomy, :with_parent, organization:, name: { en: "A great taxonomy" }) }
    let!(:another_taxonomy) { create(:taxonomy, parent: taxonomy.parent, organization:, name: { en: "Another taxonomy" }) }
    let!(:process_with_taxonomy) { create(:participatory_process, taxonomies: [taxonomy], organization:) }
    let!(:process_without_taxonomy) { create(:participatory_process, organization:) }
    let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy: taxonomy.parent, participatory_space_manifests:) }
    let(:external_taxonomy_filter) { create(:taxonomy_filter, :with_items, participatory_space_manifests:) }
    let(:participatory_space_manifests) { ["participatory_processes"] }
    let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
    let!(:another_taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: another_taxonomy) }

    context "and choosing a taxonomy" do
      before do
        visit decidim_participatory_processes.participatory_processes_path(filter: { with_any_taxonomies: { taxonomy.parent_id => [taxonomy.id] } }, locale: I18n.locale)
      end

      it "lists all processes belonging to that taxonomy" do
        within "#processes-grid" do
          expect(page).to have_content(translated(process_with_taxonomy.title))
          expect(page).to have_no_content(translated(process_without_taxonomy.title))
        end

        within "#panel-dropdown-menu-taxonomy" do
          click_filter_item "Another taxonomy"
          sleep 2
        end

        within "#processes-grid" do
          expect(page).to have_no_content(translated(process_with_taxonomy.title))
          expect(page).to have_no_content(translated(process_without_taxonomy.title))
        end

        within "#panel-dropdown-menu-taxonomy" do
          click_filter_item "Another taxonomy"
          sleep 2
        end

        within "#processes-grid" do
          expect(page).to have_content(translated(process_with_taxonomy.title))
          expect(page).to have_content(translated(process_without_taxonomy.title))
        end
      end
    end
  end
end
