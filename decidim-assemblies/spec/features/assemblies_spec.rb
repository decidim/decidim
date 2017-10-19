# frozen_string_literal: true

require "spec_helper"

describe "Assemblies", type: :feature do
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

  context "when there are no assemblies" do
    context "direct access form URL" do
      before do
        visit decidim_assemblies.assemblies_path
      end

      it "shows a message about the lack of assemblies" do
        expect(page).to have_content("No assemblies yet!")
      end
    end

    context "accessing from the homepage" do
      it "the menu link is not shown" do
        visit decidim.root_path

        within ".main-nav" do
          expect(page).to have_no_content("Assemblies")
        end
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

    context "accessing from the homepage" do
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

    context "accessing from the homepage" do
      it "the menu link is not shown" do
        visit decidim.root_path

        within ".main-nav" do
          expect(page).to have_content("Assemblies")
          click_link "Assemblies"
        end

        expect(current_path).to eq decidim_assemblies.assemblies_path
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

      expect(current_path).to eq decidim_assemblies.assembly_path(assembly)
    end
  end

  describe "when going to the assembly page" do
    let!(:assembly) { base_assembly }
    let!(:proposals_feature) { create(:feature, :published, participatory_space: assembly, manifest_name: :proposals) }
    let!(:meetings_feature) { create(:feature, :unpublished, participatory_space: assembly, manifest_name: :meetings) }

    before do
      create_list(:proposal, 3, feature: proposals_feature)
      allow(Decidim).to receive(:feature_manifests).and_return([proposals_feature.manifest, meetings_feature.manifest])

      visit decidim_assemblies.assembly_path(assembly)
    end

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

    let(:attached_to) { assembly }
    it_behaves_like "has attachments"

    context "when the assembly has some features" do
      it "shows the features" do
        within ".process-nav" do
          expect(page).to have_content(translated(proposals_feature.name, locale: :en).upcase)
          expect(page).to have_no_content(translated(meetings_feature.name, locale: :en).upcase)
        end
      end

      it "shows the stats for those features" do
        within ".process_stats" do
          expect(page).to have_content("3 PROPOSALS")
          expect(page).to_not have_content("0 MEETINGS")
        end
      end

      context "when the assembly stats are not enabled" do
        let(:show_statistics) { false }

        it "the stats for those features are not visible" do
          expect(page).not_to have_content("3 PROPOSALS")
        end
      end
    end
  end
end
