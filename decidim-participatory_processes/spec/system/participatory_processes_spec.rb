# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/has_contextual_help"

describe "Participatory Processes", type: :system do
  let(:organization) { create(:organization) }
  let(:show_metrics) { true }
  let(:show_statistics) { true }
  let(:hashtag) { true }
  let(:base_description) { { en: "Description", ca: "Descripció", es: "Descripción" } }
  let(:short_description) { { en: "Short description", ca: "Descripció curta", es: "Descripción corta" } }

  let(:base_process) do
    create(
      :participatory_process,
      :active,
      organization:,
      description: base_description,
      short_description:,
      show_metrics:,
      show_statistics:
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
    let!(:menu_content_block) { create(:content_block, organization:, manifest_name: :global_menu, scope_name: :homepage) }

    it "does not show the menu link" do
      visit decidim.root_path

      within "#home__menu" do
        expect(page).not_to have_content("Processes")
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
      create(:participatory_process, :unpublished, organization:)
      create(:participatory_process, :published)
    end

    context "and directly accessing from URL" do
      it_behaves_like "a 404 page" do
        let(:target_path) { decidim_participatory_processes.participatory_processes_path }
      end
    end

    context "and accessing from the homepage" do
      let!(:menu_content_block) { create(:content_block, organization:, manifest_name: :global_menu, scope_name: :homepage) }

      it "the menu link is not shown" do
        visit decidim.root_path

        within "#home__menu" do
          expect(page).not_to have_content("Processes")
        end
      end
    end
  end

  context "when there are some published processes" do
    let!(:participatory_process) { base_process }
    let!(:promoted_process) { create(:participatory_process, :promoted, organization:) }
    let!(:unpublished_process) { create(:participatory_process, :unpublished, organization:) }
    let!(:past_process) { create(:participatory_process, :past, organization:) }
    let!(:upcoming_process) { create(:participatory_process, :upcoming, organization:) }
    let!(:grouped_process) { create(:participatory_process, organization:) }
    let!(:group) { create(:participatory_process_group, participatory_processes: [grouped_process], organization:) }

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

      # REDESIGN_PENDING: Uncomment this test when redesign of this page
      # finished. The headings increasing levels is correct there
      # it_behaves_like "accessible page"

      context "and accessing from the homepage" do
        let!(:menu_content_block) { create(:content_block, organization:, manifest_name: :global_menu, scope_name: :homepage) }

        it "the menu link is not shown" do
          visit decidim.root_path

          within "#home__menu" do
            click_link "Processes"
          end

          expect(page).to have_current_path decidim_participatory_processes.participatory_processes_path
        end
      end

      context "with highlighted processes" do
        before do
          promoted_process.title["en"] = "D'Artagnan #{promoted_process.title["en"]}"
          promoted_process.save!
          visit decidim_participatory_processes.participatory_processes_path
        end

        # REDESIGN_PENDING: Uncomment this test when redesign of this page
        # finished. The headings increasing levels is correct there
        # it_behaves_like "accessible page"

        it "lists all the highlighted processes" do
          within "#highlighted-processes" do
            expect(page).to have_content(translated(promoted_process.title, locale: :en))
            expect(page).to have_selector("[id^='participatory_process_highlight']", count: 1)
          end
        end
      end

      it "lists the active processes" do
        within "#processes-grid" do
          within "#processes-grid h2" do
            expect(page).to have_content("3 active processes")
          end

          expect(page).to have_content(translated(participatory_process.title, locale: :en))
          expect(page).to have_content(translated(promoted_process.title, locale: :en))
          expect(page).to have_content(translated(group.title, locale: :en))
          expect(page).to have_selector("a.card__grid", count: 3)

          expect(page).not_to have_content(translated(unpublished_process.title, locale: :en))
          expect(page).not_to have_content(translated(past_process.title, locale: :en))
          expect(page).not_to have_content(translated(upcoming_process.title, locale: :en))
          expect(page).not_to have_content(translated(grouped_process.title, locale: :en))
        end
      end

      it "links to the individual process page" do
        first(".card__grid h3", text: translated(participatory_process.title, locale: :en)).click

        expect(page).to have_current_path decidim_participatory_processes.participatory_process_path(participatory_process)
      end

      context "with active steps" do
        let!(:step) { create(:participatory_process_step, participatory_process:) }
        let!(:active_step) do
          create(:participatory_process_step,
                 :active,
                 participatory_process:,
                 title: { en: "Active step", ca: "Fase activa", es: "Fase activa" })
        end

        it "links to the active step" do
          visit decidim_participatory_processes.participatory_processes_path

          within find("#processes-grid .card__grid", text: translated(participatory_process.title)) do
            within ".card__grid-metadata" do
              expect(page).to have_content("Active step")
            end
          end
        end

        context "when the active step has CTA text and url set" do
          # REDESIGN_PENDING - The process card-g is not expected to display
          # CTA. Delete the test if this is correct or implement and
          # adapt the tests
          let(:cta_path) { "my_path" }
          let(:cta_text) { { en: "Take action!", ca: "Take action!", es: "Take action!" } }

          before do
            skip "REDESIGN_PENDING - Remove or implement and adapt the tests"

            active_step.update!(cta_path:, cta_text:)
          end

          it "shows a CTA button" do
            visit decidim_participatory_processes.participatory_processes_path

            within "#participatory_process_#{participatory_process.id}" do
              expect(page).to have_link("Take action!")
            end
          end

          context "when cta_text is empty in current locale" do
            let(:cta_text) { { en: "", ca: "Take action!", es: "Take action!" } }

            it "displays the regular cta button" do
              visit decidim_participatory_processes.participatory_processes_path

              within "#participatory_process_#{participatory_process.id}" do
                expect(page).not_to have_link("Take action!")
                expect(page).to have_link("More info")
              end
            end
          end

          context "when process is promoted" do
            let(:cta_text) { { en: "Take promoted action!", ca: "Take promoted action!", es: "Take promoted action!" } }
            let!(:active_step) do
              create(:participatory_process_step,
                     :active,
                     participatory_process: promoted_process,
                     title: { en: "Active step", ca: "Fase activa", es: "Fase activa" })
            end

            it "shows a CTA button" do
              skip "REDESIGN_DETAILS: CTA button may be deprecated after redesign integration"

              visit decidim_participatory_processes.participatory_processes_path

              within "#highlighted-processes" do
                expect(page).to have_link("Take promoted action!")
              end
            end
          end

          context "when user switch locale" do
            before do
              visit decidim_participatory_processes.participatory_processes_path
              within_language_menu do
                click_link "Català"
              end
            end

            it "displays the regular cta button" do
              within "#participatory_process_#{participatory_process.id}" do
                expect(page).to have_link("Take action!", href: "/processes/#{participatory_process.slug}/my_path")
              end
            end
          end
        end
      end

      context "when there are promoted participatory process groups" do
        let!(:promoted_group) { create(:participatory_process_group, :promoted, :with_participatory_processes, organization:) }
        let(:promoted_items_titles) { page.all("#highlighted-processes .h3").map(&:text) }

        before do
          promoted_group.title["en"] = "D'Artagnan #{promoted_group.title["en"]}"
          promoted_group.save!
          visit decidim_participatory_processes.participatory_processes_path
        end

        it "shows a highligted processes section" do
          expect(page).to have_content("Highlighted processes")
        end

        it "lists only promoted groups" do
          expect(promoted_items_titles).to include(translated(promoted_group.title, locale: :en))
          expect(promoted_items_titles).not_to include(translated(group.title, locale: :en))
        end

        it "lists all the highlighted process groups" do
          within "#highlighted-processes" do
            expect(page).to have_content(translated(promoted_group.title, locale: :en))
            expect(page).to have_selector("[id^='participatory_process_highlight']", count: 1)
            expect(page).to have_selector("[id^='participatory_process_group_highlight']", count: 1)
          end
        end

        context "and promoted group has defined a CTA content block" do
          let(:cta_settings) do
            {
              button_url: "https://example.org/action",
              button_text_en: "cta text",
              description_en: "cta description"
            }
          end

          before do
            create(
              :content_block,
              organization:,
              scope_name: :participatory_process_group_homepage,
              scoped_resource_id: promoted_group.id,
              manifest_name: :cta,
              settings: cta_settings
            )
            visit decidim_participatory_processes.participatory_processes_path
          end

          it "shows a CTA button inside group card" do
            skip "REDESIGN_DETAILS: CTA button may be deprecated after redesign integration"

            within("#highlighted-processes") do
              expect(page).to have_link(cta_settings[:button_text_en], href: cta_settings[:button_url])
            end
          end

          context "and promoted group belongs to another organization" do
            let!(:promoted_group) { create(:participatory_process_group, :promoted, :with_participatory_processes) }

            it "shows a CTA button inside group card" do
              within("#highlighted-processes") do
                expect(page).not_to have_link(cta_settings[:button_text_en], href: cta_settings[:button_url])
              end
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
      let(:blocks_manifests) { [] }

      before do
        blocks_manifests.each do |manifest_name|
          create(:content_block, organization:, scope_name: :participatory_process_homepage, manifest_name:, scoped_resource_id: participatory_process.id)
        end
        visit decidim_participatory_processes.participatory_process_path(participatory_process)
      end

      context "when requesting the process path" do
        context "when hero, main_data and phase and duration blocks are enabled" do
          let(:blocks_manifests) { [:process_hero, :main_data, :extra_data] }

          it "shows the details of the given process" do
            within "[data-content]" do
              expect(page).to have_content(translated(participatory_process.title, locale: :en))
              expect(page).to have_content(translated(participatory_process.subtitle, locale: :en))
              expect(page).to have_content(translated(participatory_process.short_description, locale: :en))
              expect(page).to have_content(I18n.l(participatory_process.end_date, format: :decidim_short_with_month_name_short))
              expect(page).to have_content(participatory_process.hashtag)
            end
          end
        end

        context "when attachments blocks enabled" do
          let(:blocks_manifests) { [:related_documents, :related_images] }

          it_behaves_like "has attachments" do
            let(:attached_to) { participatory_process }
          end

          it_behaves_like "has attachment collections" do
            let(:attached_to) { participatory_process }
            let(:collection_for) { participatory_process }
          end
        end

        context "and it belongs to a group" do
          let!(:group) { create(:participatory_process_group, participatory_processes: [participatory_process], organization:) }
          let(:blocks_manifests) { [:extra_data] }

          it "has a link to the group the process belongs to" do
            visit decidim_participatory_processes.participatory_process_path(participatory_process)

            expect(page).to have_link(translated(group.title, locale: :en), href: decidim_participatory_processes.participatory_process_group_path(group))
          end
        end

        context "when it has some linked processes" do
          let(:published_process) { create(:participatory_process, :published, organization:) }
          let(:unpublished_process) { create(:participatory_process, :unpublished, organization:) }
          let(:blocks_manifests) { [:related_processes] }

          it "only shows the published linked processes" do
            participatory_process
              .link_participatory_space_resources(
                [published_process, unpublished_process],
                "related_processes"
              )
            visit decidim_participatory_processes.participatory_process_path(participatory_process)
            expect(page).to have_content(translated(published_process.title))
            expect(page).not_to have_content(translated(unpublished_process.title))
          end
        end

        context "and the process has some components" do
          let(:blocks_manifests) { [:main_data] }

          it "shows the components" do
            within ".participatory-space__nav-container" do
              expect(page).to have_content(translated(proposals_component.name, locale: :en))
              expect(page).not_to have_content(translated(meetings_component.name, locale: :en))
            end
          end

          context "and the process metrics are enabled" do
            let(:organization) { create(:organization) }
            let(:metrics) do
              Decidim.metrics_registry.filtered(highlight: true, scope: "participatory_process").each do |metric_registry|
                create(:metric, metric_type: metric_registry.metric_name, day: Time.zone.today - 1.week, organization:, participatory_space_type: Decidim::ParticipatoryProcess.name, participatory_space_id: participatory_process.id, cumulative: 5, quantity: 2)
              end
            end
            let(:blocks_manifests) { [:metrics] }

            before do
              metrics
              visit current_path
            end

            it "shows the metrics charts" do
              expect(page).to have_css("h2.h2", text: "Metrics")

              within "[data-metrics]" do
                Decidim.metrics_registry.filtered(highlight: true, scope: "participatory_process").each do |metric_registry|
                  expect(page).to have_css(%(##{metric_registry.metric_name}_chart))
                end
              end
            end

            it "renders a link to all metrics" do
              within "[data-metrics]" do
                expect(page).to have_link("Show all")
              end
            end

            it "click link" do
              click_link("Show all")
              have_current_path(decidim_participatory_processes.all_metrics_participatory_process_path(participatory_process))
            end
          end

          context "and the process statistics are enabled" do
            let(:blocks_manifests) { [:stats] }

            it "the stats for those components are visible" do
              expect(page).to have_css("[data-statistic]", count: 3)
            end
          end

          context "and the process statistics are not enabled" do
            let(:blocks_manifests) { [] }

            it "the stats for those components are not visible" do
              expect(page).not_to have_css("[data-statistics]", count: 3)
              expect(page).not_to have_css(".statistic__title", text: "Proposals")
              expect(page).not_to have_css(".statistic__number", text: "3")
            end
          end

          context "and the process metrics are not enabled" do
            let(:show_metrics) { false }

            it "the metrics for the participatory processes are not rendered" do
              expect(page).not_to have_css("h4.section-heading", text: "METRICS")
            end

            it "has no link to all metrics" do
              expect(page).not_to have_link("Show all metrics")
            end
          end

          context "and the process does not have hashtag" do
            let(:hashtag) { false }

            it "the hashtags for those components are not visible" do
              expect(page).not_to have_content("#")
            end
          end
        end

        context "when assemblies are linked to participatory process" do
          let!(:published_assembly) { create(:assembly, :published, organization:) }
          let!(:unpublished_assembly) { create(:assembly, :unpublished, organization:) }
          let!(:private_assembly) { create(:assembly, :published, :private, :opaque, organization:) }
          let!(:transparent_assembly) { create(:assembly, :published, :private, :transparent, organization:) }
          let(:blocks_manifests) { [:related_assemblies] }

          before do
            published_assembly.link_participatory_space_resources(participatory_process, "included_participatory_processes")
            unpublished_assembly.link_participatory_space_resources(participatory_process, "included_participatory_processes")
            private_assembly.link_participatory_space_resources(participatory_process, "included_participatory_processes")
            transparent_assembly.link_participatory_space_resources(participatory_process, "included_participatory_processes")
            visit decidim_participatory_processes.participatory_process_path(participatory_process)
          end

          it "display related assemblies" do
            expect(page).to have_content("Related assemblies")
            expect(page).to have_content(translated(published_assembly.title))
            expect(page).to have_content(translated(transparent_assembly.title))
            expect(page).not_to have_content(translated(unpublished_assembly.title))
            expect(page).not_to have_content(translated(private_assembly.title))
          end
        end

        # REDESIGN_PENDING - These examples have to be moved to the details
        # page
        # it_behaves_like "has embedded video in description", :base_description
        # it_behaves_like "has embedded video in description", :short_description
      end
    end
  end
end
