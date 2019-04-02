# frozen_string_literal: true

require "spec_helper"

describe "Filter Participatory Processes", type: :system do
  let(:organization) { create(:organization) }
  let(:base_process) do
    create(
      :participatory_process,
      organization: organization,
      description: { en: "Description", ca: "Descripció", es: "Descripción" },
      short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" }
    )
  end

  before do
    switch_to_host(organization.host)
  end

  context "when there are some published processes" do
    let!(:participatory_process) { base_process }
    let!(:promoted_process) { create(:participatory_process, :promoted, organization: organization) }
    let!(:unpublished_process) { create(:participatory_process, :unpublished, organization: organization) }
    let!(:past_process) { create :participatory_process, :past, organization: organization }
    let!(:upcoming_process) { create :participatory_process, :upcoming, organization: organization }

    before do
      visit decidim_participatory_processes.participatory_processes_path
    end

    context "and filtering processes by date" do
      context "and choosing 'active' processes" do
        before do
          participatory_process.update(title: "Started 1 day ago", start_date: 1.day.ago)
          promoted_process.update(title: "Started 1 year ago", start_date: 1.year.ago)
          visit decidim_participatory_processes.participatory_processes_path
        end

        it "lists the active processes ordered by start_date (descendingly)" do
          within "#processes-grid h2" do
            expect(page).to have_content("2 ACTIVE PROCESSES")
          end

          within "#processes-grid" do
            titles = page.all(".card__title")
            expect(titles.first.text).to eq("Started 1 day ago")
            expect(titles.last.text).to eq("Started 1 year ago")
          end
        end
      end

      context "and choosing 'past' processes" do
        let!(:past_process_2) { create :participatory_process, :past, organization: organization }

        before do
          past_process.update(title: "Ended 1 week ago")
          past_process_2.update(title: "Ended 1 year ago", end_date: 1.year.ago)
          within ".order-by__tabs" do
            click_link "Past"
          end
        end

        it "lists the past processes ordered by end_date (descendingly)" do
          within "#processes-grid h2" do
            expect(page).to have_content("2 PAST PROCESSES")
          end

          within "#processes-grid" do
            titles = page.all(".card__title")
            expect(titles.first.text).to eq("Ended 1 week ago")
            expect(titles.last.text).to eq("Ended 1 year ago")
          end
        end
      end

      context "and choosing 'upcoming' processes" do
        let!(:upcoming_process_2) { create :participatory_process, :upcoming, organization: organization }

        before do
          upcoming_process.update(title: "Starts 1 week from now")
          upcoming_process_2.update(title: "Starts 1 year from now", start_date: 1.year.from_now)
          within ".order-by__tabs" do
            click_link "Upcoming"
          end
        end

        it "lists the upcoming processes ordered by start_date (ascendingly)" do
          within "#processes-grid h2" do
            expect(page).to have_content("1")
          end

          within "#processes-grid" do
            titles = page.all(".card__title")
            expect(titles.first.text).to eq("Starts 1 week from now")
            expect(titles.last.text).to eq("Starts 1 year from now")
          end
        end
      end

      context "and choosing 'all' processes" do
        before do
          promoted_process.update(title: "Started just NOW")
          participatory_process.update(title: "Started 1 day ago", start_date: 1.day.ago)
          past_process.update(title: "Sarted 2 weeks ago")
          upcoming_process.update(title: "Starts 1 year from now", start_date: 1.year.from_now)
          within ".order-by__tabs" do
            click_link "All"
          end
        end

        it "lists all processes ordered by start_date (closest to current_date)" do
          within "#processes-grid h2" do
            expect(page).to have_content("4 PROCESSES")
          end

          expect(page).to have_content(translated(participatory_process.title, locale: :en))
          expect(page).to have_content(translated(promoted_process.title, locale: :en))
          expect(page).to have_content(translated(past_process.title, locale: :en))
          expect(page).to have_content(translated(upcoming_process.title, locale: :en))

          within "#processes-grid" do
            titles = page.all(".card__title")
            expect(titles[0].text).to eq("Started just NOW")
            expect(titles[1].text).to eq("Started 1 day ago")
            expect(titles[2].text).to eq("Sarted 2 weeks ago")
            expect(titles[3].text).to eq("Starts 1 year from now")
          end
        end
      end
    end

    context "and filtering processes by scope" do
      let(:process_with_scope) { create(:participatory_process, :with_scope) }

      it ""
    end
  end
end
