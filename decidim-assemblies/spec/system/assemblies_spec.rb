# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/has_contextual_help"

describe "Assemblies", type: :system do
  let(:organization) { create(:organization) }
  let(:show_statistics) { true }
  let(:base_assembly) do
    create(
      :assembly,
      organization: organization,
      description: { en: "Description", ca: "Descripció", es: "Descripción" },
      short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" },
      show_statistics: show_statistics,
      assembly_type: "others"
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
      create(:assembly, :unpublished, organization: organization)
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
    let!(:child_assembly) { create(:assembly, parent: assembly, organization: organization) }
    let!(:promoted_assembly) { create(:assembly, :promoted, organization: organization, assembly_type: "government") }
    let!(:unpublished_assembly) { create(:assembly, :unpublished, organization: organization) }

    before do
      visit decidim_assemblies.assemblies_path
    end

    it_behaves_like "editable content for admins"

    it_behaves_like "shows contextual help" do
      let(:index_path) { decidim_assemblies.assemblies_path }
      let(:manifest_name) { :assemblies }
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
        expect(page).to have_selector("article.card--full", count: 1)
      end
    end

    it "lists the parent assemblies" do
      within "#assemblies-grid" do
        within "#assemblies-grid h2" do
          expect(page).to have_content("2")
        end

        expect(page).to have_content(translated(assembly.title, locale: :en))
        expect(page).to have_content(translated(promoted_assembly.title, locale: :en))
        expect(page).to have_selector("article.card", count: 2)

        expect(page).not_to have_content(translated(child_assembly.title, locale: :en))
        expect(page).not_to have_content(translated(unpublished_assembly.title, locale: :en))
      end
    end

    context "when filtering the parent assemblies" do
      let!(:assembly3) { create(:assembly, :published, organization: organization, assembly_type: "consultative_advisory") }
      let!(:assembly4) { create(:assembly, :published, organization: organization, assembly_type: "participatory") }
      let!(:assembly5) { create(:assembly, :published, organization: organization, assembly_type: "executive") }
      let!(:assembly6) { create(:assembly, :published, organization: organization, assembly_type: "working_group") }
      let!(:assembly7) { create(:assembly, :published, organization: organization, assembly_type: "commission") }

      before do
        visit decidim_assemblies.assemblies_path
        click_button "Filter by type"
      end

      it "filters by All types" do
        click_link "All"
        expect(page).to have_selector("article.card.card--assembly", count: 7)
      end

      it "filters by Government type" do
        click_link "Government"
        expect(page).to have_selector("article.card.card--assembly", count: 1)
        expect(page).to have_content("Government")
      end

      it "filters by Executive type" do
        click_link "Executive"
        expect(page).to have_selector("article.card.card--assembly", count: 1)
        expect(page).to have_content("Executive")
      end

      it "filters by Consultative/Advisory type" do
        click_link "Consultative/Advisory"
        expect(page).to have_selector("article.card.card--assembly", count: 1)
        expect(page).to have_content("Consultative/Advisory")
      end

      it "filters by Participatory type" do
        click_link "Participatory"
        expect(page).to have_selector("article.card.card--assembly", count: 1)
        expect(page).to have_content("Participatory")
      end

      it "filters by Working group type" do
        click_link "Working group"
        expect(page).to have_selector("article.card.card--assembly", count: 1)
        expect(page).to have_content("Working group")
      end

      it "filters by Commission type" do
        click_link "Commission"
        expect(page).to have_selector("article.card.card--assembly", count: 1)
        expect(page).to have_content("Commission")
      end

      it "filters by Others type" do
        click_link "Others"
        expect(page).to have_selector("article.card.card--assembly", count: 1)
        expect(page).to have_content("Others")
      end
    end

    it "links to the individual assembly page" do
      click_link(translated(assembly.title, locale: :en))

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

  describe "when going to the assembly page" do
    let!(:assembly) { base_assembly }
    let!(:proposals_component) { create(:component, :published, participatory_space: assembly, manifest_name: :proposals) }
    let!(:meetings_component) { create(:component, :unpublished, participatory_space: assembly, manifest_name: :meetings) }

    before do
      create_list(:proposal, 3, component: proposals_component)
      allow(Decidim).to receive(:component_manifests).and_return([proposals_component.manifest, meetings_component.manifest])

      visit decidim_assemblies.assembly_path(assembly)
    end

    it_behaves_like "editable content for admins"

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

      it "shows the stats for those components" do
        within ".process_stats" do
          expect(page).to have_content("3 PROPOSALS")
          expect(page).not_to have_content("0 MEETINGS")
        end
      end

      context "when the assembly stats are not enabled" do
        let(:show_statistics) { false }

        it "the stats for those components are not visible" do
          expect(page).not_to have_content("3 PROPOSALS")
        end
      end
    end

    context "when the assembly has a child" do
      let!(:child_assembly) { create :assembly, organization: organization, parent: assembly }

      before do
        visit decidim_assemblies.assembly_path(assembly)
      end

      it "shows the children" do
        within("#assemblies-grid") do
          expect(page).to have_link translated(child_assembly.title)
        end
      end
    end
  end

  describe "when going to the assembly child page" do
    let!(:parent_assembly) { base_assembly }
    let!(:child_assembly) { create :assembly, organization: organization, parent: parent_assembly }

    before do
      visit decidim_assemblies.assembly_path(child_assembly)
    end

    it "have a link to the parent assembly" do
      expect(page).to have_link translated(parent_assembly.title)
    end
  end
end
