# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/has_contextual_help"

describe "Participatory Processes" do
  let(:organization) { create(:organization) }
  let(:hashtag) { true }
  let(:base_description) { { en: "Description", ca: "Descripció", es: "Descripción" } }
  let(:short_description) { { en: "Short description", ca: "Descripció curta", es: "Descripción corta" } }

  let(:base_process) do
    create(
      :participatory_process,
      :active,
      organization:,
      description: base_description,
      short_description:
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
          expect(page).to have_no_content("Processes")
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

      it_behaves_like "accessible page"

      context "and accessing from the homepage" do
        let!(:menu_content_block) { create(:content_block, organization:, manifest_name: :global_menu, scope_name: :homepage) }

        it "the menu link is not shown" do
          visit decidim.root_path

          within "#home__menu" do
            click_on "Processes"
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

        it_behaves_like "accessible page"

        it "lists all the highlighted processes" do
          within "#highlighted-processes" do
            expect(page).to have_content(translated(promoted_process.title, locale: :en))
            expect(page).to have_css("[id^='participatory_process_highlight']", count: 1)
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
          expect(page).to have_css("a.card__grid", count: 3)

          expect(page).to have_no_content(translated(unpublished_process.title, locale: :en))
          expect(page).to have_no_content(translated(past_process.title, locale: :en))
          expect(page).to have_no_content(translated(upcoming_process.title, locale: :en))
          expect(page).to have_no_content(translated(grouped_process.title, locale: :en))
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

          within "#processes-grid .card__grid", text: translated(participatory_process.title) do
            within ".card__grid-metadata" do
              expect(page).to have_content("Active step")
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

        it "shows a highlighted processes section" do
          expect(page).to have_content("Highlighted processes")
        end

        it "lists only promoted groups" do
          expect(promoted_items_titles).to include(translated(promoted_group.title, locale: :en))
          expect(promoted_items_titles).not_to include(translated(group.title, locale: :en))
        end

        it "lists all the highlighted process groups" do
          within "#highlighted-processes" do
            expect(page).to have_content(translated(promoted_group.title, locale: :en))
            expect(page).to have_css("[id^='participatory_process_highlight']", count: 1)
            expect(page).to have_css("[id^='participatory_process_group_highlight']", count: 1)
          end
        end
      end
    end
  end

  it_behaves_like "followable space content for users" do
    let!(:participatory_process) { base_process }
    let!(:user) { create(:user, :confirmed, organization:) }
    let(:followable) { participatory_process }
    let(:followable_path) { decidim_participatory_processes.participatory_process_path(participatory_process) }
  end

  context "when going to the participatory process page" do
    let!(:participatory_process) { base_process }
    let!(:proposals_component) { create(:component, :published, participatory_space: participatory_process, manifest_name: :proposals) }
    let!(:meetings_component) { create(:component, :unpublished, participatory_space: participatory_process, manifest_name: :meetings) }

    before do
      create_list(:proposal, 3, component: proposals_component)
      allow(Decidim).to receive(:component_manifests).and_return([proposals_component.manifest, meetings_component.manifest])
    end

    describe "page title" do
      it "has the participatory process title in the show page" do
        visit decidim_participatory_processes.participatory_process_path(participatory_process)

        expect(page).to have_title("#{translated(participatory_process.title)} - #{translated(organization.name)}")
      end
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
          let(:blocks_manifests) { [:hero, :main_data, :extra_data, :metadata] }

          it "shows the details of the given process" do
            within "[data-content]" do
              expect(page).to have_content("About this process")
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
              expect(page).to have_content(I18n.l(participatory_process.start_date, format: :decidim_short_with_month_name_short))
              expect(page).to have_content(I18n.l(participatory_process.end_date, format: :decidim_short_with_month_name_short))
              expect(page).to have_content(participatory_process.hashtag)
            end
          end

          it_behaves_like "has embedded video in description", :base_description
          it_behaves_like "has embedded video in description", :short_description
        end

        context "when attachments blocks enabled" do
          let(:blocks_manifests) { [:related_documents, :related_images] }

          it_behaves_like "has attachments content blocks" do
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
            expect(page).to have_no_content(translated(unpublished_process.title))
          end
        end

        context "and the process has some components" do
          let(:blocks_manifests) { [:main_data] }

          it "shows the components" do
            within ".participatory-space__nav-container" do
              expect(page).to have_content(translated(proposals_component.name, locale: :en))
              expect(page).to have_no_content(translated(meetings_component.name, locale: :en))
            end
          end

          context "and the process statistics are enabled" do
            let(:blocks_manifests) { [:hero, :stats] }

            it "the stats for those components are visible" do
              expect(page).to have_css("[data-statistic]", count: 3)
            end

            it_behaves_like "accessible page"
          end

          context "and the process statistics are not enabled" do
            let(:blocks_manifests) { [] }

            it "the stats for those components are not visible" do
              expect(page).to have_no_css("[data-statistics]", count: 3)
              expect(page).to have_no_css(".statistic__title", text: "Proposals")
              expect(page).to have_no_css(".statistic__number", text: "3")
            end
          end

          context "and the process does not have hashtag" do
            let(:hashtag) { false }

            it "the hashtags for those components are not visible" do
              expect(page).to have_no_content("#")
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
            expect(page).to have_no_content(translated(unpublished_assembly.title))
            expect(page).to have_no_content(translated(private_assembly.title))
          end
        end
      end
    end
  end
end
