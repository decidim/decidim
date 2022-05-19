# frozen_string_literal: true

shared_examples "proposals wizards" do |options|
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let(:organization) { create :organization }

  let!(:category) { create :category, participatory_space: participatory_process }
  let!(:scope) { create :scope, organization: organization }
  let!(:user) { create :user, :confirmed, organization: organization }
  let(:scoped_participatory_process) { create(:participatory_process, :with_steps, organization: organization, scope: scope) }

  let(:address) { "Plaça Santa Jaume, 1, 08002 Barcelona" }
  let(:latitude) { 41.3825 }
  let(:longitude) { 2.1772 }

  let(:proposal_title) { "More sidewalks and less roads" }
  let(:proposal_body) { "Cities need more people, not more cars" }

  let!(:component) do
    create(:proposal_component,
           :with_creation_enabled,
           manifest: manifest,
           participatory_space: participatory_process)
  end
  let(:component_path) { Decidim::EngineRouter.main_proxy(component) }

  shared_examples_for "without address" do
    context "when in step_1: Create your proposal" do
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

      context "when the back button is clicked" do
        before do
          click_link "Back"
        end

        it "redirects to proposals_path" do
          expect(page).to have_content("PROPOSALS")
          expect(page).to have_content("New proposal")
        end
      end
    end

    context "when in step_2: Compare" do
      context "with similar results" do
        before do
          create(:proposal, title: "More sidewalks and less roads", body: "Cities need more people, not more cars", component: component)
          create(:proposal, title: "More sidewalks and less roadways", body: "Green is always better", component: component)
          visit_component
          click_link "New proposal"
          within ".new_proposal" do
            fill_in :proposal_title, with: proposal_title
            fill_in :proposal_body, with: proposal_body

            find("*[type=submit]").click
          end
        end

        it "show previous and current step_2 highlighted" do
          within ".wizard__steps" do
            expect(page).to have_css(".step--active", count: 1)
            expect(page).to have_css(".step--past", count: 1)
            expect(page).to have_css(".step--active.step_2")
          end
        end

        it "shows similar proposals" do
          expect(page).to have_content("SIMILAR PROPOSALS (2)")
          expect(page).to have_css(".card--proposal", text: "More sidewalks and less roads")
          expect(page).to have_css(".card--proposal", count: 2)
        end

        it "show continue button" do
          expect(page).to have_link("Continue")
        end

        it "does not show the back button" do
          expect(page).not_to have_link("Back")
        end
      end

      context "without similar results" do
        before do
          visit_component
          click_link "New proposal"
          within ".new_proposal" do
            fill_in :proposal_title, with: proposal_title
            fill_in :proposal_body, with: proposal_body

            find("*[type=submit]").click
          end
        end

        it "redirects to step_3: complete" do
          within ".section-heading" do
            expect(page).to have_content("COMPLETE YOUR PROPOSAL")
          end
          expect(page).to have_css(".edit_proposal")
        end

        it "shows no similar proposal found callout" do
          within ".flash.callout.success" do
            expect(page).to have_content("Well done! No similar proposals found")
          end
        end
      end
    end

    context "when in step_3: Complete" do
      before do
        visit_component
        click_link "New proposal"
        within ".new_proposal" do
          fill_in :proposal_title, with: proposal_title
          fill_in :proposal_body, with: proposal_body

          find("*[type=submit]").click
        end
      end

      it "show previous and current step_3 highlighted" do
        within ".wizard__steps" do
          expect(page).to have_css(".step--active", count: 1)
          expect(page).to have_css(".step--past", count: 2)
          expect(page).to have_css(".step--active.step_3")
        end
      end

      it "show form and submit button" do
        expect(page).to have_field("Title", with: proposal_title)
        expect(page).to have_field("Body", with: proposal_body)
        expect(page).to have_button("Send")
      end

      context "when the back button is clicked" do
        before do
          create(:proposal, title: proposal_title, component: component)
          click_link "Back"
        end

        it "redirects to step_3: complete" do
          expect(page).to have_content("SIMILAR PROPOSALS (1)")
        end
      end
    end

    context "when in step_4: Publish" do
      let!(:proposal_draft) { create(:proposal, :draft, users: [user], component: component, title: proposal_title, body: proposal_body) }

      before do
        visit component_path.preview_proposal_path(proposal_draft)
      end

      it "show current step_4 highlighted" do
        within ".wizard__steps" do
          expect(page).to have_css(".step--active", count: 1)
          expect(page).to have_css(".step--past", count: 3)
          expect(page).to have_css(".step--active.step_4")
        end
      end

      it "shows a preview" do
        expect(page).to have_content(proposal_title)
        expect(page).to have_content(user.name)
        expect(page).to have_content(proposal_body)
      end

      it "shows a publish button" do
        expect(page).to have_selector("button", text: "Publish")
      end

      it "shows a modify proposal link" do
        expect(page).to have_selector("a", text: "Modify the proposal")
      end

      it "doesn't show a geocoded address" do
        expect(page).not_to have_content("ADDRESS")
        expect(page).not_to have_css(".card__content.address")
      end

      context "when the back button is clicked" do
        before do
          click_link "Back"
        end

        it "redirects to edit the proposal draft" do
          expect(page).to have_content("EDIT PROPOSAL DRAFT")
        end
      end
    end

    context "when editing a proposal draft" do
      context "when in step_4: edit proposal draft" do
        let!(:proposal_draft) { create(:proposal, :draft, users: [user], component: component, title: proposal_title, body: proposal_body) }
        let!(:edit_draft_proposal_path) do
          "#{Decidim::EngineRouter.main_proxy(component).proposal_path(proposal_draft)}/edit_draft"
        end

        before do
          visit edit_draft_proposal_path
        end

        it "show current step_4 highlighted" do
          within ".wizard__steps" do
            expect(page).to have_css(".step--active", count: 1)
            expect(page).to have_css(".step--past", count: 2)
            expect(page).to have_css(".step--active.step_3")
          end
        end

        it "can discard the draft" do
          within ".card__content" do
            expect(page).to have_content("Discard this draft")
            click_link "Discard this draft"
          end

          accept_confirm

          within_flash_messages do
            expect(page).to have_content "successfully"
          end
          expect(page).to have_css(".step--active.step_1")
        end

        it "renders a Preview button" do
          within ".card__content" do
            expect(page).to have_content("Preview")
          end
        end
      end
    end
  end
  shared_examples_for "with address" do
    let!(:component) do
      create(:proposal_component,
             :with_creation_enabled,
             :with_geocoding_enabled,
             manifest: manifest,
             participatory_space: participatory_process)
    end

    context "when in step_4: edit proposal draft" do
      let!(:proposal_draft) { create(:proposal, :draft, users: [user], address: address, component: component, title: proposal_title, body: proposal_body) }

      before do
        proposal_draft.update!(latitude: latitude, longitude: longitude)
        visit "#{component_path.proposal_path(proposal_draft)}/edit_draft"
      end

      it "allows filling an empty address and unchecking the has address checkbox" do
        within "form.edit_proposal" do
          fill_in :proposal_address, with: ""
        end
        uncheck "proposal_has_address"
        click_button "Preview"

        expect(page).to have_content(proposal_title)
        expect(page).to have_content(proposal_body)
        expect(page).not_to have_field("proposal_address")
        expect(page).not_to have_field("proposal_longitude")
        expect(page).not_to have_field("proposal_latitude")
      end
    end

    context "when in step_4: Publish" do
      let!(:proposal_draft) { create(:proposal, :draft, users: [user], address: address, component: component, title: proposal_title, body: proposal_body) }

      before do
        stub_geocoding(address, [latitude, longitude])
        proposal_draft.update!(latitude: latitude)
        proposal_draft.update!(longitude: longitude)
        visit component_path.preview_proposal_path(proposal_draft)
      end

      it "show current step_4 highlighted" do
        within ".wizard__steps" do
          expect(page).to have_css(".step--active", count: 1)
          expect(page).to have_css(".step--past", count: 3)
          expect(page).to have_css(".step--active.step_4")
        end
      end

      it "shows a preview" do
        expect(page).to have_content(proposal_title)
        expect(page).to have_content(user.name)
        expect(page).to have_content(proposal_body)

        expect(page).to have_content("ADDRESS")
        expect(page).to have_css(".card__content.address")
      end

      it "shows a publish button" do
        expect(page).to have_selector("button", text: "Publish")
      end

      it "shows a modify proposal link" do
        expect(page).to have_selector("a", text: "Modify the proposal")
      end

      context "when the back button is clicked" do
        before do
          click_link "Back"
        end

        it "redirects to edit the proposal draft" do
          expect(page).to have_content("EDIT PROPOSAL DRAFT")
        end
      end

      context "when there is no address" do
        let!(:proposal_draft) { create(:proposal, :draft, users: [user], address: nil, component: component, title: proposal_title, body: proposal_body) }

        it "doesn't shows a preview" do
          expect(page).to have_content(proposal_title)
          expect(page).to have_content(user.name)
          expect(page).to have_content(proposal_body)

          expect(page).not_to have_content("ADDRESS")
          expect(page).not_to have_css(".card__content.address")
        end
      end
    end
  end

  context "when creating a new proposal" do
    before do
      login_as user, scope: :user
      visit_component
      click_link "New proposal"
    end

    it_behaves_like "with address" if options[:with_address]
    it_behaves_like "without address" unless options[:with_address]
  end
end
