# frozen_string_literal: true

require "spec_helper"

describe "Result embeds", type: :feature do
  include_context "feature"
  let(:manifest_name) { "results" }

  let!(:result) { create(:result, feature: feature) }

  context "when visiting the embed page for a result" do
    before do
      visit resource_locator(result).path
      visit "#{current_path}/embed"
    end

    it "renders the page correctly" do
      expect(page).to have_i18n_content(result.title)
      expect(page).to have_content(organization.name)
    end

    context "when the participatory_space is a process" do
      it "shows the process name" do
        expect(page).to have_i18n_content(participatory_process.title)
      end
    end

    context "when the participatory_space is an assembly" do
      let(:assembly) do
        create(:assembly, organization: organization)
      end
      let(:participatory_space) { assembly }

      it "shows the assembly name" do
        expect(page).to have_i18n_content(assembly.title)
      end
    end
  end
end
