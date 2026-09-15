# frozen_string_literal: true

require "spec_helper"

describe "Accountability Breadcrumb" do
  include_context "with a component"

  let(:manifest_name) { "accountability" }
  let!(:results) { create_list(:result, 5, component:) }

  describe "index" do
    let(:path) { decidim_participatory_process_accountability.results_path(participatory_process_slug: participatory_process.slug, component_id: component.id, locale: I18n.locale) }

    before do
      visit path
    end

    it "shows the correct information in breadcrumb (space, component)" do
      within(".menu-bar") do
        expect(page).to have_text(translated(component.participatory_space.title))
        expect(page).to have_text(translated(component.name))
      end
    end
  end

  describe "show" do
    let(:path) { decidim_participatory_process_accountability.result_path(id: result.id, participatory_process_slug: participatory_process.slug, component_id: component.id, locale: I18n.locale) }
    let(:results_count) { 1 }
    let(:result) { results.first }

    before do
      visit path
    end

    it "shows the correct information in breadcrumb (space, component, result)" do
      within(".menu-bar") do
        expect(page).to have_text(translated(component.participatory_space.title))
        expect(page).to have_text(translated(component.name))
        expect(page).to have_text(translated(result.title))
      end
    end

    context "with subresults" do
      let!(:subresults) { create_list(:result, 3, component:, parent: result) }
      let(:first_subresult) { subresults.first }

      before do
        visit current_path
      end

      it "shows the correct information in breadcrumb (space, component, result, subresult)" do
        click_on translated(first_subresult.title)
        within(".menu-bar") do
          expect(page).to have_text(translated(component.participatory_space.title))
          expect(page).to have_text(translated(component.name))
          expect(page).to have_text(translated(result.title))
          expect(page).to have_text(translated(first_subresult.title))
        end
      end
    end
  end

  describe "versions", versioning: true do
    let!(:result) { create(:result, progress: 25.0, component:) }
    let(:path) { decidim_participatory_process_accountability.result_path(id: result.id, participatory_process_slug: participatory_process.slug, component_id: component.id, locale: I18n.locale) }

    before do
      Decidim.traceability.update!(
        result,
        "test suite",
        progress: 50.0
      )
      visit path

      click_on "see other versions"
    end

    it "shows the correct information in breadcrumb (space, component, result)" do
      within(".menu-bar") do
        expect(page).to have_text(translated(component.participatory_space.title))
        expect(page).to have_text(translated(component.name))
        expect(page).to have_text(translated(result.title))
      end
    end
  end
end
