# frozen_string_literal: true

require "spec_helper"

describe "Proposal", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let!(:category) { create :category, participatory_space: participatory_process }
  let!(:scope) { create :scope, organization: organization }
  let!(:user) { create :user, :confirmed, organization: organization }
  let(:scoped_participatory_process) { create(:participatory_process, :with_steps, organization: organization, scope: scope) }

  let(:address) { "Carrer Pare Llaurador 113, baixos, 08224 Terrassa" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }

  let(:proposal_title) { "Oriol for president" }
  let(:proposal_body) { "He will solve everything" }

  let!(:component) do
    create(:proposal_component,
           :with_creation_enabled,
           manifest: manifest,
           participatory_space: participatory_process)
  end

  let!(:proposal_draft) { create(:proposal, :draft, component: component, title: proposal_title, body: proposal_body) }

  let!(:compare_proposal_path) do
    Decidim::EngineRouter.main_proxy(component).compare_proposal_path(proposal_draft)
  end

  let!(:preview_proposal_path) do
    Decidim::EngineRouter.main_proxy(component).preview_proposal_path(proposal_draft)
  end

  context "when creating a new proposal" do
    before do
      login_as user, scope: :user
      visit_component
      click_link "New proposal"
    end

    context "when in step_1: Start" do
      it "show current step_1 highlighted" do
        within ".wizard__steps" do
          expect(page).to have_css(".step--active", count: 1)
          expect(page).to have_css(".step--past", count: 0)
          expect(page).to have_css(".step--active.step_1")
        end
      end

      it "fill in title and body" do
        within ".card__content form" do
          fill_in :proposal_title, with: proposal_title
          fill_in :proposal_body, with: proposal_body
          find("*[type=submit]").click
        end
      end
    end

    context "when in step_2: Compare" do
      context "with similar results" do
        before do
          create(:proposal, title: "Agusti for president", body: "He will solve everything", component: component)
          create(:proposal, title: "Homer for president", body: "He will not solve everything", component: component)
          visit compare_proposal_path
        end

        it "show previous and current step_2 highlighted" do
          within ".wizard__steps" do
            expect(page).to have_css(".step--active", count: 1)
            expect(page).to have_css(".step--past", count: 1)
            expect(page).to have_css(".step--active.step_2")
          end
        end
        it "shows similar proposals" do
          expect(page).to have_css(".card--proposal", text: "Agusti for president")
          expect(page).to have_css(".card--proposal", count: 2)
        end

        it "show continue button" do
          expect(page).to have_content("My proposal is different")
        end
      end

      context "without similar results" do
        before do
          visit compare_proposal_path
        end

        it "redirects to the publish step" do
          expect(page).to have_content("PUBLISH YOUR PROPOSAL")
        end

        it "shows no similar proposal found" do
          within ".flash.callout.success" do
            expect(page).to have_content("Well done! No similar proposals found")
          end
        end
      end
    end

    context "when in step_3: Publish" do
      before do
        visit preview_proposal_path
      end

      it "show current step_3 highlighted" do
        within ".wizard__steps" do
          expect(page).to have_css(".step--active", count: 1)
          expect(page).to have_css(".step--past", count: 2)
          expect(page).to have_css(".step--active.step_3")
        end
      end

      it "shows a preview" do
        expect(page).to have_css(".card.card--proposal", count: 1)
      end

      it "shows a publish button" do
        expect(page).to have_selector("button", text: "Publish")
      end

      it "shows a modify proposal link" do
        expect(page).to have_selector("a", text: "Modify the proposal")
      end
    end
  end
end
