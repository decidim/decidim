# frozen_string_literal: true

shared_examples "proposals wizards" do |options|
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :confirmed, organization:) }

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

        expect(page).to have_css("[data-active]", text: "Publish your proposal")
        expect(page).to have_css("[data-past]", count: 1)
      end

      context "when the back button is clicked" do
        before do
          click_on "Back"
        end

        it "redirects to proposals_path" do
          expect(page).to have_content("Proposals")
          expect(page).to have_content("New proposal")
        end
      end
    end

    context "when in step_2: Publish" do
      let!(:proposal_draft) { create(:proposal, :draft, users: [user], component:, title: proposal_title, body: proposal_body) }

      before do
        visit component_path.preview_proposal_path(proposal_draft)
      end

      it "show current step_2 highlighted" do
        within "#wizard-steps" do
          expect(page).to have_css("[data-active]", text: "Publish your proposal")
          expect(page).to have_css("[data-past]", count: 1)
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
        expect(page).to have_css("a", text: "Modify the proposal")
      end

      it "does not show a geocoded address" do
        expect(page).to have_no_content("ADDRESS")
        expect(page).to have_no_css(".card__content.address")
      end

      context "when the back button is clicked" do
        before do
          click_on "Modify the proposal"
        end

        it "redirects to edit the proposal draft" do
          expect(page).to have_content("Edit proposal draft")
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
          click_on "Images"
          within "#panel-images" do
            expect(find("img")["alt"]).to eq(".jpg")
          end

          click_on "Documents"
          within "#panel-documents" do
            expect(find("a.card__list-title")["innerHTML"]).to include("&lt;svg onload=alert('ALERT')&gt;.pdf")
          end
        end
      end
    end

    context "when editing a proposal draft" do
      context "when in step_2: edit proposal draft" do
        let!(:proposal_draft) { create(:proposal, :draft, users: [user], component:, title: proposal_title, body: proposal_body) }
        let!(:edit_draft_proposal_path) do
          "#{Decidim::EngineRouter.main_proxy(component).proposal_path(proposal_draft)}/edit_draft"
        end

        before do
          visit edit_draft_proposal_path
        end

        it "show current step_2 highlighted" do
          within "#wizard-steps" do
            expect(page).to have_css("[data-active]", text: "Create your proposal")
            expect(page).to have_css("[data-past]", count: 0)
          end
        end

        it "can discard the draft" do
          expect(page).to have_link("Discard this draft")
          click_on "Discard this draft"

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

    context "when in step_2: edit proposal draft" do
      let!(:proposal_draft) { create(:proposal, :draft, users: [user], address:, component:, title: proposal_title, body: proposal_body) }

      before do
        proposal_draft.update!(latitude:, longitude:)
        visit "#{component_path.proposal_path(proposal_draft)}/edit_draft"
      end

      it "allows filling an empty address" do
        within "form.edit_proposal" do
          fill_in :proposal_address, with: ""
        end
        click_on "Preview"

        expect(page).to have_content(proposal_title)
        expect(page).to have_content(proposal_body)
        expect(page).to have_no_field("proposal_address")
        expect(page).to have_no_field("proposal_longitude")
        expect(page).to have_no_field("proposal_latitude")
      end
    end

    context "when in step_2: Publish" do
      let!(:proposal_draft) { create(:proposal, :draft, users: [user], address:, component:, title: proposal_title, body: proposal_body) }

      before do
        stub_geocoding(address, [latitude, longitude])
        proposal_draft.update!(latitude:)
        proposal_draft.update!(longitude:)
        visit component_path.preview_proposal_path(proposal_draft)
      end

      it "show current step_2 highlighted" do
        within "#wizard-steps" do
          expect(page).to have_css("[data-active]", text: "Publish your proposal")
          expect(page).to have_css("[data-past]", count: 1)
        end
      end

      it "shows the activity logs" do
        click_on "Publish"

        visit decidim.last_activities_path
        expect(page).to have_content("New proposal: #{translated(proposal_draft.title)}")

        within "#filters" do
          find("a", class: "filter", text: "Proposal", match: :first).click
        end
        expect(page).to have_content("New proposal: #{translated(proposal_draft.title)}")
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
        expect(page).to have_css("a", text: "Modify the proposal")
      end

      context "when the back button is clicked" do
        before do
          click_on "Modify the proposal"
        end

        it "redirects to edit the proposal draft" do
          expect(page).to have_content("Edit proposal draft")
        end
      end

      context "when there is no address" do
        let!(:proposal_draft) { create(:proposal, :draft, users: [user], address: nil, component:, title: proposal_title, body: proposal_body) }

        it "does not shows a preview" do
          expect(page).to have_content(proposal_title)
          expect(page).to have_content(user.name)
          expect(page).to have_content(proposal_body)

          expect(page).to have_no_css(".card__content.address")
        end
      end
    end
  end

  context "when creating a new proposal" do
    before do
      login_as user, scope: :user
      visit_component
      click_on "New proposal"
    end

    it_behaves_like "with address" if options[:with_address]
    it_behaves_like "without address" unless options[:with_address]
  end
end
