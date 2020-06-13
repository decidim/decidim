# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/has_contextual_help"

describe "Participatory Processes", type: :system do
  let(:organization) { create(:organization) }
  let(:show_metrics) { true }
  let(:show_statistics) { true }
  let(:hashtag) { true }
  let(:base_process) do
    create(
      :participatory_process,
      :active,
      organization: organization,
      description: { en: "Description", ca: "Descripció", es: "Descripción" },
      short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" },
      show_metrics: show_metrics,
      show_statistics: show_statistics
    )
  end

  before do
    switch_to_host(organization.host)
  end

  context "when there are no processes and directly accessing form URL" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_participatory_processes.participatory_processes_path }
    end
  end

  context "when there are no processes and accessing from the homepage" do
    it "does not show the menu link" do
      visit decidim.root_path

      within ".main-nav" do
        expect(page).to have_no_content("Processes")
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

    context "and directly accessing from URL" do
      it_behaves_like "a 404 page" do
        let(:target_path) { decidim_participatory_processes.participatory_processes_path }
      end
    end

    context "and accessing from the homepage" do
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
    let!(:past_process) { create :participatory_process, :past, organization: organization }
    let!(:upcoming_process) { create :participatory_process, :upcoming, organization: organization }
    let!(:grouped_process) { create :participatory_process, organization: organization }
    let!(:group) { create :participatory_process_group, participatory_processes: [grouped_process], organization: organization }

    it_behaves_like "shows contextual help" do
      let(:index_path) { decidim_participatory_processes.participatory_processes_path }
      let(:manifest_name) { :participatory_processes }
    end

    it_behaves_like "editable content for admins" do
      let(:target_path) { decidim_participatory_processes.participatory_processes_path }
    end

    context "when requesting the processes path" do
      before do
        visit decidim_participatory_processes.participatory_processes_path
      end

      context "and accessing from the homepage" do
        it "the menu link is not shown" do
          visit decidim.root_path

          within ".main-nav" do
            expect(page).to have_content("Processes")
            click_link "Processes"
          end

          expect(page).to have_current_path decidim_participatory_processes.participatory_processes_path
        end
      end

      it "lists all the highlighted processes" do
        within "#highlighted-processes" do
          expect(page).to have_content(translated(promoted_process.title, locale: :en))
          expect(page).to have_selector("article.card--full", count: 1)
        end
      end

      it "lists the active processes" do
        within "#processes-grid" do
          within "#processes-grid h3" do
            expect(page).to have_content("3 ACTIVE PROCESSES")
          end

          expect(page).to have_content(translated(participatory_process.title, locale: :en))
          expect(page).to have_content(translated(promoted_process.title, locale: :en))
          expect(page).to have_content(translated(group.name, locale: :en))
          expect(page).to have_selector("article.card", count: 3)

          expect(page).to have_no_content(translated(unpublished_process.title, locale: :en))
          expect(page).to have_no_content(translated(past_process.title, locale: :en))
          expect(page).to have_no_content(translated(upcoming_process.title, locale: :en))
          expect(page).to have_no_content(translated(grouped_process.title, locale: :en))
        end
      end

      it "links to the individual process page" do
        click_link(translated(participatory_process.title, locale: :en))

        expect(page).to have_current_path decidim_participatory_processes.participatory_process_path(participatory_process)
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
              expect(page).to have_content("CURRENT PHASE:\nActive step")
            end
          end
        end
      end
    end
  end

  context "when going to the participatory process page" do
    let!(:participatory_process) { base_process }
    let!(:proposals_component) { create(:component, :published, participatory_space: participatory_process, manifest_name: :proposals) }
    let!(:meetings_component) { create(:component, :unpublished, participatory_space: participatory_process, manifest_name: :meetings) }

    before do
      create_list(:proposal, 3, component: proposals_component)
      allow(Decidim).to receive(:component_manifests).and_return([proposals_component.manifest, meetings_component.manifest])
    end

    it_behaves_like "editable content for admins" do
      let(:target_path) { decidim_participatory_processes.participatory_process_path(participatory_process) }
    end

    context "when requesting the participatory process path" do
      before do
        visit decidim_participatory_processes.participatory_process_path(participatory_process)
      end

      context "when requesting the process path" do
        it "shows the details of the given process" do
          within "main" do
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

        it_behaves_like "has attachments" do
          let(:attached_to) { participatory_process }
        end

        it_behaves_like "has attachment collections" do
          let(:attached_to) { participatory_process }
          let(:collection_for) { participatory_process }
        end

        context "when it has some linked processes" do
          let(:published_process) { create :participatory_process, :published, organization: organization }
          let(:unpublished_process) { create :participatory_process, :unpublished, organization: organization }

          it "only shows the published linked processes" do
            participatory_process
              .link_participatory_space_resources(
                [published_process, unpublished_process],
                "related_processes"
              )
            visit decidim_participatory_processes.participatory_process_path(participatory_process)
            expect(page).to have_content(translated(published_process.title))
            expect(page).to have_no_content(translated(unpublished_process.title))
          end
        end

        context "and the process has some components" do
          it "shows the components" do
            within ".process-nav" do
              expect(page).to have_content(translated(proposals_component.name, locale: :en).upcase)
              expect(page).to have_no_content(translated(meetings_component.name, locale: :en).upcase)
            end
          end

          context "and the process metrics are enabled" do
            let(:organization) { create(:organization) }
            let(:metrics) do
              Decidim.metrics_registry.filtered(highlight: true, scope: "participatory_process").each do |metric_registry|
                create(:metric, metric_type: metric_registry.metric_name, day: Time.zone.today - 1.week, organization: organization, participatory_space_type: Decidim::ParticipatoryProcess.name, participatory_space_id: participatory_process.id, cumulative: 5, quantity: 2)
              end
            end

            before do
              metrics
              visit current_path
            end

            it "shows the metrics charts" do
              expect(page).to have_css("h3.section-heading", text: "METRICS")

              within "#metrics" do
                Decidim.metrics_registry.filtered(highlight: true, scope: "participatory_process").each do |metric_registry|
                  expect(page).to have_css(%(##{metric_registry.metric_name}_chart))
                end
              end
            end

            it "renders a link to all metrics" do
              within "#metrics" do
                expect(page).to have_link("Show all metrics")
              end
            end

            it "click link" do
              click_link("Show all metrics")
              have_current_path(decidim_participatory_processes.all_metrics_participatory_process_path(participatory_process))
            end
          end

          context "and the process statistics are enabled" do
            let(:show_statistics) { true }

            it "the stats for those components are visible" do
              within "#participatory_process-statistics" do
                expect(page).to have_css("h4.section-heading", text: "STATISTICS")
                expect(page).to have_css(".process-stats__title", text: "PROPOSALS")
                expect(page).to have_css(".process-stats__number", text: "3")
                expect(page).to have_no_css(".process-stats__title", text: "MEETINGS")
                expect(page).to have_no_css(".process-stats__number", text: "0")
              end
            end
          end

          context "and the process statistics are not enabled" do
            let(:show_statistics) { false }

            it "the stats for those components are not visible" do
              expect(page).to have_no_css("h4.section-heading", text: "STATISTICS")
              expect(page).to have_no_css(".process-stats__title", text: "PROPOSALS")
              expect(page).to have_no_css(".process-stats__number", text: "3")
            end
          end

          context "and the process metrics are not enabled" do
            let(:show_metrics) { false }

            it "the metrics for the participatory processes are not rendered" do
              expect(page).to have_no_css("h4.section-heading", text: "METRICS")
            end

            it "has no link to all metrics" do
              expect(page).to have_no_link("Show all metrics")
            end
          end

          context "and the process doesn't have hashtag" do
            let(:hashtag) { false }

            it "the hashtags for those components are not visible" do
              expect(page).to have_no_content("#")
            end
          end
        end

        context "when assemblies are linked to participatory process" do
          let!(:published_assembly) { create(:assembly, :published, organization: organization) }
          let!(:unpublished_assembly) { create(:assembly, :unpublished, organization: organization) }
          let!(:private_assembly) { create(:assembly, :published, :private, :opaque, organization: organization) }
          let!(:transparent_assembly) { create(:assembly, :published, :private, :transparent, organization: organization) }

          before do
            published_assembly.link_participatory_space_resources(participatory_process, "included_participatory_processes")
            unpublished_assembly.link_participatory_space_resources(participatory_process, "included_participatory_processes")
            private_assembly.link_participatory_space_resources(participatory_process, "included_participatory_processes")
            transparent_assembly.link_participatory_space_resources(participatory_process, "included_participatory_processes")
            visit decidim_participatory_processes.participatory_process_path(participatory_process)
          end

          it "display related assemblies" do
            expect(page).to have_content("RELATED ASSEMBLIES")
            expect(page).to have_content(translated(published_assembly.title))
            expect(page).to have_content(translated(transparent_assembly.title))
            expect(page).to have_no_content(translated(unpublished_assembly.title))
            expect(page).to have_no_content(translated(private_assembly.title))
          end
        end
      end
    end
  end
end
