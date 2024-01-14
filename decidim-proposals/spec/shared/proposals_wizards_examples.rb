# frozen_string_literal: true

shared_examples "proposals wizards" do |options|
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let(:organization) { create(:organization) }

  let!(:category) { create(:category, participatory_space: participatory_process) }
  let!(:scope) { create(:scope, organization:) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let(:scoped_participatory_process) { create(:participatory_process, :with_steps, organization:, scope:) }

  let(:address) { "Plaça Santa Jaume, 1, 08002 Barcelona" }
  let(:latitude) { 41.3825 }
  let(:longitude) { 2.1772 }

  let(:proposal_title) { "More sidewalks and less roads" }
  let(:proposal_body) { "Cities need more people, not more cars" }

  let!(:component) do
    create(:proposal_component,
           :with_creation_enabled,
           manifest:,
           participatory_space: participatory_process)
  end
  let(:component_path) { Decidim::EngineRouter.main_proxy(component) }

  shared_examples_for "without address" do
    context "when in step_1: Create your proposal" do
      it "show current step_1 highlighted" do
        within "#wizard-steps" do
          expect(page).to have_css("[data-active]", text: "Create your proposal")
          expect(page).to have_css("[data-past]", count: 0)
        end
      end

      it "fill in title and body" do
        within "form.new_proposal" do
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
          expect(page).to have_content("Proposals")
          expect(page).to have_content("New proposal")
        end
      end
    end

    context "when in step_2: Compare" do
      context "with similar results" do
        before do
          create(:proposal, title: "More sidewalks and less roads", body: "Cities need more people, not more cars", component:)
          create(:proposal, title: "More sidewalks and less roadways", body: "Green is always better", component:)
          visit_component
          click_link "New proposal"
          within ".new_proposal" do
            fill_in :proposal_title, with: proposal_title
            fill_in :proposal_body, with: proposal_body

            find("*[type=submit]").click
          end
        end

        it "show previous and current step_2 highlighted" do
          within "#wizard-steps" do
            expect(page).to have_css("[data-active]", text: "Compare")
            expect(page).to have_css("[data-past]", count: 1)
          end
        end

        it "shows similar proposals" do
          expect(page).to have_content("Similar Proposals (2)")
          expect(page).to have_css("[id^='proposals__proposal']", text: "More sidewalks and less roads")
          expect(page).to have_css("[id^='proposals__proposal']", count: 2)
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
          expect(page).to have_content("Complete your proposal")
          expect(page).to have_css(".edit_proposal")
        end

        it "shows no similar proposal found callout" do
          within "[data-alert-box].success" do
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
        within "#wizard-steps" do
          expect(page).to have_css("[data-active]", text: "Complete")
          expect(page).to have_css("[data-past]", count: 2)
        end
      end

      it "show form and submit button" do
        expect(page).to have_field("Title", with: proposal_title)
        expect(page).to have_field("Body", with: proposal_body)
        expect(page).to have_button("Send")
      end

      context "when the back button is clicked" do
        before do
          create(:proposal, title: proposal_title, component:)
          click_link "Back"
        end

        it "redirects to step_3: complete" do
          expect(page).to have_content("Similar Proposals (1)")
        end
      end
    end

    context "when in step_4: Publish" do
      let!(:proposal_draft) { create(:proposal, :draft, users: [user], component:, title: proposal_title, body: proposal_body) }

      before do
        visit component_path.preview_proposal_path(proposal_draft)
      end

      it "show current step_4 highlighted" do
        within "#wizard-steps" do
          expect(page).to have_css("[data-active]", text: "Publish your proposal")
          expect(page).to have_css("[data-past]", count: 3)
        end
      end

      it "shows a preview" do
        expect(page).to have_content(proposal_title)
        expect(page).to have_content(user.name)
        expect(page).to have_content(proposal_body)
      end

      it "shows a publish button" do
        expect(page).to have_button(text: "Publish")
      end

      it "shows a modify proposal link" do
        expect(page).to have_selector("a", text: "Modify the proposal")
      end

      it "does not show a geocoded address" do
        expect(page).not_to have_content("ADDRESS")
        expect(page).not_to have_css(".card__content.address")
      end

      context "when the back button is clicked" do
        before do
          click_link "Modify the proposal"
        end

        it "redirects to edit the proposal draft" do
          expect(page).to have_content("Edit Proposal Draft")
        end
      end

      context "with attachments" do
        let!(:component) do
          create(
            :proposal_component,
            :with_creation_enabled,
            :with_attachments_allowed,
            participatory_space: participatory_process
          )
        end

        let!(:photo) { create(:attachment, :with_image, title: { en: "<svg onload=alert('ALERT')>.jpg" }, weight: 0, attached_to: proposal_draft) }
        let!(:file) { create(:attachment, :with_pdf, title: { en: "<svg onload=alert('ALERT')>.pdf" }, weight: 1, attached_to: proposal_draft) }

        before do
          expect(page).to have_content(translated(proposal_draft.title))

          visit component_path.preview_proposal_path(proposal_draft)
        end

        it "displays the attachments correctly" do
          within "#panel-images" do
            expect(find("img")["alt"]).to eq(".jpg")
          end

          click_button("trigger-documents")
          within "#panel-documents" do
            expect(find("a.card__list-title")["innerHTML"]).to include("&lt;svg onload=alert('ALERT')&gt;.pdf")
          end
        end
      end
    end

    context "when editing a proposal draft" do
      context "when in step_4: edit proposal draft" do
        let!(:proposal_draft) { create(:proposal, :draft, users: [user], component:, title: proposal_title, body: proposal_body) }
        let!(:edit_draft_proposal_path) do
          "#{Decidim::EngineRouter.main_proxy(component).proposal_path(proposal_draft)}/edit_draft"
        end

        before do
          visit edit_draft_proposal_path
        end

        it "show current step_4 highlighted" do
          within "#wizard-steps" do
            expect(page).to have_css("[data-active]", text: "Complete")
            expect(page).to have_css("[data-past]", count: 2)
          end
        end

        it "can discard the draft" do
          expect(page).to have_link("Discard this draft")
          click_link "Discard this draft"

          accept_confirm

          within_flash_messages do
            expect(page).to have_content "successfully"
          end
          within "#wizard-steps" do
            expect(page).to have_css("[data-active]", text: "Create your proposal")
            expect(page).to have_css("[data-past]", count: 0)
          end
        end

        it "renders a Preview button" do
          expect(page).to have_button("Preview")
        end
      end
    end
  end

  shared_examples_for "with address" do
    let!(:component) do
      create(:proposal_component,
             :with_creation_enabled,
             :with_geocoding_enabled,
             manifest:,
             participatory_space: participatory_process)
    end

    context "when in step_4: edit proposal draft" do
      let!(:proposal_draft) { create(:proposal, :draft, users: [user], address:, component:, title: proposal_title, body: proposal_body) }

      before do
        proposal_draft.update!(latitude:, longitude:)
        visit "#{component_path.proposal_path(proposal_draft)}/edit_draft"
      end

      it "allows filling an empty address" do
        within "form.edit_proposal" do
          fill_in :proposal_address, with: ""
        end
        click_button "Preview"

        expect(page).to have_content(proposal_title)
        expect(page).to have_content(proposal_body)
        expect(page).not_to have_field("proposal_address")
        expect(page).not_to have_field("proposal_longitude")
        expect(page).not_to have_field("proposal_latitude")
      end
    end

    context "when in step_4: Publish" do
      let!(:proposal_draft) { create(:proposal, :draft, users: [user], address:, component:, title: proposal_title, body: proposal_body) }

      before do
        stub_geocoding(address, [latitude, longitude])
        proposal_draft.update!(latitude:)
        proposal_draft.update!(longitude:)
        visit component_path.preview_proposal_path(proposal_draft)
      end

      it "show current step_4 highlighted" do
        within "#wizard-steps" do
          expect(page).to have_css("[data-active]", text: "Publish your proposal")
          expect(page).to have_css("[data-past]", count: 3)
        end
      end

      it "shows a preview" do
        expect(page).to have_content(proposal_title)
        expect(page).to have_content(user.name)
        expect(page).to have_content(proposal_body)

        expect(page).to have_css(".static-map__container")
      end

      it "shows a publish button" do
        expect(page).to have_button(text: "Publish")
      end

      it "shows a modify proposal link" do
        expect(page).to have_selector("a", text: "Modify the proposal")
      end

      context "when the back button is clicked" do
        before do
          click_link "Modify the proposal"
        end

        it "redirects to edit the proposal draft" do
          expect(page).to have_content("Edit Proposal Draft")
        end
      end

      context "when there is no address" do
        let!(:proposal_draft) { create(:proposal, :draft, users: [user], address: nil, component:, title: proposal_title, body: proposal_body) }

        it "does not shows a preview" do
          expect(page).to have_content(proposal_title)
          expect(page).to have_content(user.name)
          expect(page).to have_content(proposal_body)

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
