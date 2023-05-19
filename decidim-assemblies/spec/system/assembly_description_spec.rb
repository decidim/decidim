# frozen_string_literal: true

require "spec_helper"

describe "Assembly description", type: :system do
  let(:organization) { create(:organization) }
  let(:base_description) { { en: "Description", ca: "Descripció", es: "Descripción" } }
  let(:assembly) do
    create(
      :assembly,
      organization:,
      description: base_description,
      short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" }
    )
  end

  before do
    skip "REDESIGN_PENDING - Adapt these examples to metadata and main data content blocks and remove this file"

    switch_to_host(organization.host)
  end

  context "when the assembly does not exist" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_assemblies.description_assembly_path(99_999_999) }
    end
  end

  describe "when going to the assembly description page" do
    before do
      visit decidim_assemblies.description_assembly_path(assembly)
      visit decidim_assemblies.description_assembly_path(assembly)
    end

    it "shows the details of the given assembly" do
      within "[data-content]" do
        expect(page).to have_content("About this assembly")
        expect(page).to have_content(translated(assembly.title, locale: :en))
        expect(page).to have_content(translated(assembly.description, locale: :en))
        expect(page).to have_content(translated(assembly.meta_scope, locale: :en))
        expect(page).to have_content(translated(assembly.developer_group, locale: :en))
        expect(page).to have_content(translated(assembly.local_area, locale: :en))
        expect(page).to have_content(translated(assembly.target, locale: :en))
        expect(page).to have_content(translated(assembly.participatory_scope, locale: :en))
        expect(page).to have_content(translated(assembly.participatory_structure, locale: :en))
        expect(page).to have_content("Duration")
        expect(page).to have_content("Closing date")
        expect(page).to have_content(I18n.l(assembly.duration, format: :decidim_short))
        expect(page).to have_content(I18n.l(assembly.closing_date, format: :decidim_short))
      end
    end

    context "when duration and closing_date are not set" do
      let(:assembly) do
        create(
          :assembly,
          organization:,
          description: base_description,
          duration:,
          closing_date:
        )
      end
      let(:duration) { nil }
      let(:closing_date) { nil }

      it "shows indefinite duration without closing date" do
        expect(page).to have_content("Duration Indefinite")
        expect(page).to have_no_content("Closing date")
      end
    end

    it_behaves_like "has embedded video in description", :base_description
  end
end
