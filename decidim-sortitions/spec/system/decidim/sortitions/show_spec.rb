# frozen_string_literal: true

require "spec_helper"

describe "show" do
  include_context "with a component"
  let(:manifest_name) { "sortitions" }

  context "when shows the sortition component" do
    let!(:sortition) { create(:sortition, component:) }

    before do
      visit_component
      find("#sortitions .card__list").click
    end

    it "shows the sortition additional info" do
      expect(page).to have_content(sortition.additional_info[:en])
    end

    it "shows the sortition witnesses" do
      expect(page).to have_content(sortition.witnesses[:en])
    end
  end

  context "when sortition result" do
    let(:sortition) { create(:sortition, component:) }
    let!(:proposals) do
      create_list(:proposal, 10,
                  component: sortition.decidim_proposals_component,
                  created_at: sortition.request_timestamp - 1.day,
                  skip_injection: true)
    end

    before do
      sortition.update(selected_proposals: Decidim::Sortitions::Admin::Draw.for(sortition))
      visit_component
      find("#sortitions .card__list").click
    end

    context "when votes are enabled" do
      let!(:decidim_proposals_component) { create(:proposal_component, :with_votes_enabled, organization: component.organization) }
      let!(:sortition) { create(:sortition, component:, decidim_proposals_component:) }

      it "shows all selected proposals" do
        sortition.proposals.each do |p|
          expect(page).to have_content(translated(p.title))
        end
      end
    end

    it "there are selected proposals" do
      expect(sortition.selected_proposals).not_to be_empty
    end

    it "shows all selected proposals" do
      sortition.proposals.each do |p|
        expect(page).to have_content(translated(p.title))
      end
    end

    it "shows a banner links back to the result" do
      proposal = sortition.proposals.last

      within "#proposals" do
        click_on translated(proposal.title)
      end

      expect(page).to have_content("Included in #{translated(sortition.title)}")
    end
  end

  context "when cancelled sortition" do
    let(:witnesses) { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    let(:additional_info) { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    let(:cancel_reason) { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    let!(:sortition) { create(:sortition, :cancelled, component:, witnesses:, additional_info:, cancel_reason:) }

    before do
      page.visit "#{main_component_path(component)}?filter[with_any_state]=cancelled"
      find("#sortitions .card__list").click
    end

    context "when the field is additional_info" do
      it_behaves_like "has embedded video in description", :additional_info
    end

    it "shows the cancel reasons" do
      expect(page).to have_content(sortition.cancel_reason[:en])
    end
  end
end
