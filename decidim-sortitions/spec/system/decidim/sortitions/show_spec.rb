# frozen_string_literal: true

require "spec_helper"

describe "show", type: :system do
  include_context "with a component"
  let(:manifest_name) { "sortitions" }

  context "when shows the sortition component" do
    let!(:sortition) { create(:sortition, component:) }

    before do
      visit_component
      click_link "View"
    end

    it "shows the sortition additional info" do
      expect(page).to have_content(sortition.additional_info[:en])
    end

    it "shows the sortition witnesses" do
      expect(page).to have_content(sortition.witnesses[:en])
    end

    it_behaves_like "going back to list button"
  end

  context "when sortition result" do
    let(:sortition) { create(:sortition, component:) }
    let!(:proposals) do
      create_list(:proposal, 10,
                  component: sortition.decidim_proposals_component,
                  created_at: sortition.request_timestamp - 1.day)
    end

    before do
      sortition.update(selected_proposals: Decidim::Sortitions::Admin::Draw.for(sortition))
      visit_component
      click_link "View"
    end

    it "There are selected proposals" do
      expect(sortition.selected_proposals).not_to be_empty
    end

    it "Shows all selected proposals" do
      sortition.proposals.each do |p|
        expect(page).to have_content(translated(p.title))
      end
    end
  end

  context "when cancelled sortition" do
    let!(:sortition) { create(:sortition, :cancelled, component:) }

    before do
      page.visit "#{main_component_path(component)}?filter[with_any_state]=cancelled"
      click_link "View"
    end

    it "shows the cancel reasons" do
      expect(page).to have_content(sortition.cancel_reason[:en])
    end
  end
end
