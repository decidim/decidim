# frozen_string_literal: true

require "spec_helper"

describe "Index proposals", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  context "when there are proposals" do
    let!(:proposals) { create_list(:proposal, 3, component:) }

    it "doesn't display empty message" do
      visit_component

      expect(page).to have_no_content("There is no proposal yet")
    end
  end

  context "when checking withdrawn proposals" do
    context "when there are no withrawn proposals" do
      let!(:proposals) { create_list(:proposal, 3, component:) }

      before do
        visit_component
        click_link "See all withdrawn proposals"
      end

      it "shows an empty page with a message" do
        expect(page).to have_content("There isn't any proposal with this criteria")
        within ".callout.warning" do
          expect(page).to have_content("You are viewing the list of proposals withdrawn by their authors. ")
        end
      end
    end

    context "when there are withrawn proposals" do
      let!(:proposals) { create_list(:proposal, 3, component:) }
      let!(:withdrawn_proposals) { create_list(:proposal, 3, :withdrawn, component:) }

      before do
        visit_component
        click_link "See all withdrawn proposals"
      end

      it "shows all the withdrawn proposals" do
        expect(page).to have_css(".card--proposal.alert", count: 3)
        within ".callout.warning" do
          expect(page).to have_content("You are viewing the list of proposals withdrawn by their authors.")
        end
      end
    end
  end

  context "when there are no proposals" do
    context "when there are no filters" do
      it "shows generic empty message" do
        visit_component

        expect(page).to have_content("There is no proposal yet")
      end
    end

    context "when there are filters" do
      let!(:proposals) { create(:proposal, :with_answer, :accepted, component:) }

      it "shows filters empty message" do
        visit_component

        uncheck "Accepted"

        expect(page).to have_content("There isn't any proposal with this criteria")
      end
    end
  end
end
