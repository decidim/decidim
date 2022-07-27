# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/has_contextual_help"

describe "Assemblies", type: :system do
  let(:organization) { create(:organization) }
  let(:show_statistics) { true }
  let(:base_assembly) do
    create(
      :assembly,
      :with_type,
      organization:,
      description: { en: "Description", ca: "Descripció", es: "Descripción" },
      short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" },
      show_statistics:
    )
  end

  before do
    switch_to_host(organization.host)
  end

  context "when there are no assemblies and directly accessing from URL" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_assemblies.assemblies_path }
    end
  end

  context "when there are no assemblies and accessing from the homepage" do
    it "the menu link is not shown" do
      visit decidim.root_path

      within ".main-nav" do
        expect(page).to have_no_content("Assemblies")
      end
    end
  end

  context "when the assembly does not exist" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_assemblies.assembly_path(99_999_999) }
    end
  end

  context "when there are some assemblies and all are unpublished" do
    before do
      create(:assembly, :unpublished, organization:)
      create(:assembly, :published)
    end

    context "and directly accessing from URL" do
      it_behaves_like "a 404 page" do
        let(:target_path) { decidim_assemblies.assemblies_path }
      end
    end

    context "and accessing from the homepage" do
      it "the menu link is not shown" do
        visit decidim.root_path

        within ".main-nav" do
          expect(page).to have_no_content("Assemblies")
        end
      end
    end
  end

  context "when there are some published assemblies" do
    let!(:assembly) { base_assembly }
    let!(:child_assembly) { create(:assembly, parent: assembly, organization:) }
    let!(:promoted_assembly) { create(:assembly, :promoted, organization:) }
    let!(:unpublished_assembly) { create(:assembly, :unpublished, organization:) }

    it_behaves_like "editable content for admins" do
      let(:target_path) { decidim_assemblies.assemblies_path }
    end

    it_behaves_like "shows contextual help" do
      let(:index_path) { decidim_assemblies.assemblies_path }
      let(:manifest_name) { :assemblies }
    end

    context "and requesting the asseblies path" do
      before do
        visit decidim_assemblies.assemblies_path
      end

      context "and accessing from the homepage" do
        it "the menu link is shown" do
          visit decidim.root_path

          within ".main-nav" do
            expect(page).to have_content("Assemblies")
            click_link "Assemblies"
          end

          expect(page).to have_current_path decidim_assemblies.assemblies_path
        end
      end

      it "lists all the highlighted assemblies" do
        within "#highlighted-assemblies" do
          expect(page).to have_content(translated(promoted_assembly.title, locale: :en))
          expect(page).to have_selector(".card--full", count: 1)
        end
      end

      it "lists the parent assemblies" do
        within "#parent-assemblies" do
          within "#parent-assemblies h3" do
            expect(page).to have_content("2")
          end

          expect(page).to have_content(translated(assembly.title, locale: :en))
          expect(page).to have_content(translated(promoted_assembly.title, locale: :en))
          expect(page).to have_selector(".card", count: 2)
          expect(page).to have_selector(".card.card--stack", count: 1)

          expect(page).not_to have_content(translated(child_assembly.title, locale: :en))
          expect(page).not_to have_content(translated(unpublished_assembly.title, locale: :en))
        end
      end

      it "links to the individual assembly page" do
        first(".card__link", text: translated(assembly.title, locale: :en)).click

        expect(page).to have_current_path decidim_assemblies.assembly_path(assembly)
      end

      it "shows the organizational chart" do
        within "#assemblies-chart" do
          within ".js-orgchart" do
            expect(page).to have_selector(".svg-chart-container")

            within ".svg-chart-container" do
              expect(page).to have_selector("g.node", count: 2)
            end
          end
        end
      end
    end
  end

  describe "when going to the assembly page" do
    let!(:assembly) { base_assembly }
    let!(:proposals_component) { create(:component, :published, participatory_space: assembly, manifest_name: :proposals) }
    let!(:meetings_component) { create(:component, :unpublished, participatory_space: assembly, manifest_name: :meetings) }

    before do
      create_list(:proposal, 3, component: proposals_component)
      allow(Decidim).to receive(:component_manifests).and_return([proposals_component.manifest, meetings_component.manifest])
    end

    it_behaves_like "editable content for admins" do
      let(:target_path) { decidim_assemblies.assembly_path(assembly) }
    end

    context "and requesting the assembly path" do
      before do
        visit decidim_assemblies.assembly_path(assembly)
      end

      it "shows the details of the given assembly" do
        within "main" do
          expect(page).to have_content(translated(assembly.title, locale: :en))
          expect(page).to have_content(translated(assembly.subtitle, locale: :en))
          expect(page).to have_content(translated(assembly.description, locale: :en))
          expect(page).to have_content(translated(assembly.short_description, locale: :en))
          expect(page).to have_content(translated(assembly.meta_scope, locale: :en))
          expect(page).to have_content(translated(assembly.developer_group, locale: :en))
          expect(page).to have_content(translated(assembly.local_area, locale: :en))
          expect(page).to have_content(translated(assembly.target, locale: :en))
          expect(page).to have_content(translated(assembly.participatory_scope, locale: :en))
          expect(page).to have_content(translated(assembly.participatory_structure, locale: :en))
          expect(page).to have_content(assembly.hashtag)
        end
      end

      it_behaves_like "has attachments" do
        let(:attached_to) { assembly }
      end

      context "when the assembly has some components" do
        it "shows the components" do
          within ".process-nav" do
            expect(page).to have_content(translated(proposals_component.name, locale: :en).upcase)
            expect(page).to have_no_content(translated(meetings_component.name, locale: :en).upcase)
          end
        end
      end

      context "and the process statistics are enabled" do
        let(:show_statistics) { true }

        it "renders the stats for those components are visible" do
          within ".section-statistics" do
            expect(page).to have_css("h3.section-heading", text: "STATISTICS")
            expect(page).to have_css(".statistic__title", text: "PROPOSALS")
            expect(page).to have_css(".statistic__number", text: "3")
            expect(page).to have_no_css(".statistic__title", text: "MEETINGS")
            expect(page).to have_no_css(".statistic__number", text: "0")
          end
        end
      end

      context "and the process statistics are not enabled" do
        let(:show_statistics) { false }

        it "doesn't render the stats for those components that are not visible" do
          expect(page).to have_no_css("h4.section-heading", text: "STATISTICS")
          expect(page).to have_no_css(".statistic__title", text: "PROPOSALS")
          expect(page).to have_no_css(".statistic__number", text: "3")
        end
      end

      context "when the assembly has children assemblies" do
        let!(:child_assembly) { create :assembly, organization:, parent: assembly, weight: 0 }
        let!(:second_child_assembly) { create :assembly, organization:, parent: assembly, weight: 1 }
        let!(:unpublished_child_assembly) { create :assembly, :unpublished, organization:, parent: assembly }

        before do
          visit decidim_assemblies.assembly_path(assembly)
        end

        it "shows only the published children assemblies" do
          within("#assemblies-grid") do
            expect(page).to have_link translated(child_assembly.title)
            expect(page).not_to have_link translated(unpublished_child_assembly.title)
          end
        end

        it "shows the children assemblies by weigth" do
          expect(page).to have_selector("#assemblies-grid .row .column:first-child", text: child_assembly.title[:en])
          expect(page).to have_selector("#assemblies-grid .row .column:last-child", text: second_child_assembly.title[:en])
        end
      end

      context "when the assembly has children private and transparent assemblies" do
        let!(:private_transparent_child_assembly) { create :assembly, organization:, parent: assembly, private_space: true, is_transparent: true }
        let!(:private_transparent_unpublished_child_assembly) { create :assembly, :unpublished, organization:, parent: assembly, private_space: true, is_transparent: true }

        before do
          visit decidim_assemblies.assembly_path(assembly)
        end

        it "shows only the published, private and transparent children assemblies" do
          within("#assemblies-grid") do
            expect(page).to have_link translated(private_transparent_child_assembly.title)
            expect(page).not_to have_link translated(private_transparent_unpublished_child_assembly.title)
          end
        end
      end

      context "when the assembly has children private and not transparent assemblies" do
        let!(:private_child_assembly) { create :assembly, organization:, parent: assembly, private_space: true, is_transparent: false }
        let!(:private_unpublished_child_assembly) { create :assembly, :unpublished, organization:, parent: assembly, private_space: true, is_transparent: false }

        before do
          visit decidim_assemblies.assembly_path(assembly)
        end

        it "not shows any children assemblies" do
          expect(page).not_to have_css("div#assemblies-grid")
        end
      end
    end
  end

  describe "when going to the assembly child page" do
    let!(:parent_assembly) { base_assembly }
    let!(:child_assembly) { create :assembly, organization:, parent: parent_assembly }

    before do
      visit decidim_assemblies.assembly_path(child_assembly)
    end

    it "have a link to the parent assembly" do
      expect(page).to have_link translated(parent_assembly.title)
    end
  end
end
