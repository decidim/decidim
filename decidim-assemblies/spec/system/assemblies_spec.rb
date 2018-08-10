# frozen_string_literal: true

require "spec_helper"

describe "Assemblies", type: :system do
  let(:organization) { create(:organization) }
  let(:show_statistics) { true }
  let(:base_assembly) do
    create(
      :assembly,
      organization: organization,
      description: { en: "Description", ca: "Descripció", es: "Descripción" },
      short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" },
      show_statistics: show_statistics
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
    let!(:promoted_assembly) { create(:assembly, :promoted, organization: organization) }
    let!(:unpublished_assembly) { create(:assembly, :unpublished, organization: organization) }

    before do
      visit decidim_assemblies.assemblies_path
    end

    it_behaves_like "editable content for admins"

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

    it "lists all the assemblies" do
      within "#assemblies-grid" do
        within "#assemblies-grid h2" do
          expect(page).to have_content("2")
        end

        expect(page).to have_content(translated(assembly.title, locale: :en))
        expect(page).to have_content(translated(promoted_assembly.title, locale: :en))
        expect(page).to have_selector("article.card", count: 2)

        expect(page).not_to have_content(translated(unpublished_assembly.title, locale: :en))
      end
    end

    it "links to the individual assembly page" do
      click_link(translated(assembly.title, locale: :en))

      expect(page).to have_current_path decidim_assemblies.assembly_path(assembly)
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
      within "div.wrapper" do
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
