# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assemblies", type: :system do
  include_context "when admin administrating an assembly"

  let(:model_name) { assembly.class.model_name }
  let(:resource_controller) { Decidim::Assemblies::Admin::AssembliesController }

  shared_examples "creating an assembly" do
    let(:image1_filename) { "city.jpeg" }
    let(:image1_path) { Decidim::Dev.asset(image1_filename) }

    let(:image2_filename) { "city2.jpeg" }
    let(:image2_path) { Decidim::Dev.asset(image2_filename) }

    before do
      click_link "New assembly"
    end

    it "creates a new assembly" do
      within ".new_assembly" do
        fill_in_i18n(
          :assembly_title,
          "#assembly-title-tabs",
          en: "My assembly",
          es: "Mi proceso participativo",
          ca: "El meu procés participatiu"
        )
        fill_in_i18n(
          :assembly_subtitle,
          "#assembly-subtitle-tabs",
          en: "Subtitle",
          es: "Subtítulo",
          ca: "Subtítol"
        )
        fill_in_i18n_editor(
          :assembly_short_description,
          "#assembly-short_description-tabs",
          en: "Short description",
          es: "Descripción corta",
          ca: "Descripció curta"
        )
        fill_in_i18n_editor(
          :assembly_description,
          "#assembly-description-tabs",
          en: "A longer description",
          es: "Descripción más larga",
          ca: "Descripció més llarga"
        )

        fill_in :assembly_slug, with: "slug"
        fill_in :assembly_hashtag, with: "#hashtag"
        fill_in :assembly_weight, with: 1
        attach_file :assembly_hero_image, image1_path
        attach_file :assembly_banner_image, image2_path

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within ".container" do
        expect(page).to have_current_path decidim_admin_assemblies.assemblies_path(q: { parent_id_eq: parent_assembly&.id })
        expect(page).to have_content("My assembly")
      end
    end
  end

  context "when managing parent assemblies" do
    let(:parent_assembly) { nil }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_assemblies.assemblies_path
    end

    it_behaves_like "manage assemblies"
    it_behaves_like "creating an assembly"

    describe "listing parent assemblies" do
      it_behaves_like "filtering collection by published/unpublished"
      it_behaves_like "filtering collection by private/public"
    end
  end

  context "when managing child assemblies" do
    let!(:parent_assembly) { create :assembly, organization: organization }
    let!(:child_assembly) { create :assembly, organization: organization, parent: parent_assembly }
    let(:assembly) { child_assembly }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_assemblies.assemblies_path
      within find("tr", text: translated(parent_assembly.title)) do
        click_link "Assemblies"
      end
    end

    it_behaves_like "manage assemblies"
    it_behaves_like "creating an assembly"

    describe "listing child assemblies" do
      it_behaves_like "filtering collection by published/unpublished" do
        let!(:published_space) { child_assembly }
        let!(:unpublished_space) { create(:assembly, :unpublished, parent: parent_assembly, organization: organization) }
      end

      it_behaves_like "filtering collection by private/public" do
        let!(:public_space) { child_assembly }
        let!(:private_space) { create(:assembly, :private, parent: parent_assembly, organization: organization) }
      end
    end
  end
end
