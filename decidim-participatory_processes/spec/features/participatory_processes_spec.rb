# frozen_string_literal: true

require "spec_helper"

describe "Participatory Processes", type: :feature do
  let(:organization) { create(:organization) }
  let(:show_statistics) { true }
  let(:base_process) do
    create(
      :participatory_process,
      organization: organization,
      description: { en: "Description", ca: "Descripció", es: "Descripción" },
      short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" },
      show_statistics: show_statistics
    )
  end

  before do
    switch_to_host(organization.host)
  end

  context "when there are no processes" do
    context "direct access form URL" do
      it_behaves_like "a 404 page" do
        let(:target_path) { decidim_participatory_processes.participatory_processes_path }
      end
    end

    context "accessing from the homepage" do
      it "the menu link is not shown" do
        visit decidim.root_path

        within ".main-nav" do
          expect(page).to have_no_content("Processes")
        end
      end
    end
  end

  context "when the process does not exist" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_participatory_processes.participatory_process_path(99_999_999) }
    end
  end

  context "when there are some processes and all are unpublished" do
    before do
      create(:participatory_process, :unpublished, organization: organization)
      create(:participatory_process, :published)
    end

    context "direct access from URL" do
      it_behaves_like "a 404 page" do
        let(:target_path) { decidim_participatory_processes.participatory_processes_path }
      end
    end

    context "accessing from the homepage" do
      it "the menu link is not shown" do
        visit decidim.root_path

        within ".main-nav" do
          expect(page).to have_no_content("Processes")
        end
      end
    end
  end

  context "when there are some published processes" do
    let!(:participatory_process) { base_process }
    let!(:promoted_process) { create(:participatory_process, :promoted, organization: organization) }
    let!(:unpublished_process) { create(:participatory_process, :unpublished, organization: organization) }

    before do
      visit decidim_participatory_processes.participatory_processes_path
    end

    context "accessing from the homepage" do
      it "the menu link is not shown" do
        visit decidim.root_path

        within ".main-nav" do
          expect(page).to have_content("Processes")
          click_link "Processes"
        end

        expect(current_path).to eq decidim_participatory_processes.participatory_processes_path
      end
    end

    it "lists all the highlighted processes" do
      within "#highlighted-processes" do
        expect(page).to have_content(translated(promoted_process.title, locale: :en))
        expect(page).to have_selector("article.card--full", count: 1)
      end
    end

    it "lists all the processes" do
      within "#processes-grid" do
        within "#processes-grid h2" do
          expect(page).to have_content("2")
        end

        expect(page).to have_content(translated(participatory_process.title, locale: :en))
        expect(page).to have_content(translated(promoted_process.title, locale: :en))
        expect(page).to have_selector("article.card", count: 2)

        expect(page).to have_no_content(translated(unpublished_process.title, locale: :en))
      end
    end

    it "links to the individual process page" do
      click_link(translated(participatory_process.title, locale: :en))

      expect(current_path).to eq decidim_participatory_processes.participatory_process_path(participatory_process)
    end

    context "filtering processes" do
      let!(:past_process) { create :participatory_process, :past, organization: organization }
      let!(:upcoming_process) { create :participatory_process, :upcoming, organization: organization }

      it "list the active processes by default" do
        expect(page).to have_no_content(translated(past_process.title, locale: :en))
        expect(page).to have_no_content(translated(upcoming_process.title, locale: :en))
      end

      context "choosing 'past' processes" do
        before do
          within ".order-by__tabs" do
            click_link "Past"
          end
        end

        it "list the past processes" do
          within "#processes-grid h2" do
            expect(page).to have_content("1")
          end

          expect(page).to have_content(translated(past_process.title, locale: :en))
        end
      end

      context "choosing 'upcoming' processes" do
        before do
          within ".order-by__tabs" do
            click_link "Upcoming"
          end
        end

        it "list the past processes" do
          within "#processes-grid h2" do
            expect(page).to have_content("1")
          end

          expect(page).to have_content(translated(upcoming_process.title, locale: :en))
        end
      end
    end

    context "with active steps" do
      let!(:step) { create(:participatory_process_step, participatory_process: participatory_process) }
      let!(:active_step) do
        create(:participatory_process_step,
               :active,
               participatory_process: participatory_process,
               title: { en: "Active step", ca: "Fase activa", es: "Fase activa" })
      end

      it "links to the active step" do
        visit decidim_participatory_processes.participatory_processes_path

        within find("#processes-grid .column", text: translated(participatory_process.title)) do
          within ".card__footer" do
            expect(page).to have_content("Current step: Active step")
          end
        end
      end
    end
  end

  describe "when going to the participatory process page" do
    let!(:participatory_process) { base_process }
    let!(:proposals_feature) { create(:feature, :published, participatory_space: participatory_process, manifest_name: :proposals) }
    let!(:meetings_feature) { create(:feature, :unpublished, participatory_space: participatory_process, manifest_name: :meetings) }

    before do
      create_list(:proposal, 3, feature: proposals_feature)
      allow(Decidim).to receive(:feature_manifests).and_return([proposals_feature.manifest, meetings_feature.manifest])

      visit decidim_participatory_processes.participatory_process_path(participatory_process)
    end

    it "shows the details of the given process" do
      within "div.wrapper" do
        expect(page).to have_content(translated(participatory_process.title, locale: :en))
        expect(page).to have_content(translated(participatory_process.subtitle, locale: :en))
        expect(page).to have_content(translated(participatory_process.description, locale: :en))
        expect(page).to have_content(translated(participatory_process.short_description, locale: :en))
        expect(page).to have_content(translated(participatory_process.meta_scope, locale: :en))
        expect(page).to have_content(translated(participatory_process.developer_group, locale: :en))
        expect(page).to have_content(translated(participatory_process.local_area, locale: :en))
        expect(page).to have_content(translated(participatory_process.target, locale: :en))
        expect(page).to have_content(translated(participatory_process.participatory_scope, locale: :en))
        expect(page).to have_content(translated(participatory_process.participatory_structure, locale: :en))
        expect(page).to have_content(I18n.l(participatory_process.end_date, format: :long))
        expect(page).to have_content(participatory_process.hashtag)
      end
    end

    let(:attached_to) { participatory_process }
    it_behaves_like "has attachments"

    context "when the process has some features" do
      it "shows the features" do
        within ".process-nav" do
          expect(page).to have_content(translated(proposals_feature.name, locale: :en).upcase)
          expect(page).to have_no_content(translated(meetings_feature.name, locale: :en).upcase)
        end
      end

      it "shows the stats for those features" do
        within ".process_stats" do
          expect(page).to have_content("3 PROPOSALS")
          expect(page).to have_no_content("0 MEETINGS")
        end
      end

      context "when the process stats are not enabled" do
        let(:show_statistics) { false }

        it "the stats for those features are not visible" do
          expect(page).to have_no_content("3 PROPOSALS")
        end
      end
    end
  end
end
