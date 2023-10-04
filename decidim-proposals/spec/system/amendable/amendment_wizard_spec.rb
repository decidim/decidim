# frozen_string_literal: true

require "spec_helper"

describe "Amendment Wizard", type: :system do
  let!(:component) { create(:proposal_component, :with_amendments_enabled) }
  let!(:proposal) { create(:proposal, title: { en: "More roads and less sidewalks" }, component:) }
  let!(:user) { create(:user, :confirmed, organization: component.organization) }
  let(:proposal_path) { Decidim::ResourceLocatorPresenter.new(proposal).path }

  let(:title) { translated "More sidewalks and less roads" }
  let(:body) { translated "Cities need more people, not more cars" }

  before do
    switch_to_host(component.organization.host)
  end

  context "when amending a proposal" do
    before do
      login_as user, scope: :user
      visit proposal_path
      click_link "Amend"
    end

    context "and in step_1: Create your amendment" do
      it "shows the current step_1 highlighted" do
        within "#wizard-steps" do
          expect(page).to have_css("[aria-current]", count: 1)
          expect(page).to have_css("[aria-current]:nth-child(1)")
        end
      end

      it "shows the new amendment form" do
        expect(page).to have_content("Create Amendment Draft")

        within ".new_amendment" do
          fill_in :amendment_emendation_params_title, with: title
          fill_in :amendment_emendation_params_body, with: body
          expect(page).to have_content("Create")
          find("*[type=submit]").click
        end
      end

      context "when the back button is clicked" do
        before do
          click_link "Back"
        end

        it "redirects to the proposal page" do
          expect(page).to have_content(translated(proposal.title))
          expect(page).to have_css("#amend-button")
        end
      end
    end

    context "and in step_2: Compare your amendment" do
      context "with similar results" do
        let!(:emendation) { create(:proposal, title: { en: title }, body: { en: body }, component:) }
        let!(:amendment) { create(:amendment, amendable: proposal, emendation:) }

        before do
          within ".new_amendment" do
            fill_in :amendment_emendation_params_title, with: title
            fill_in :amendment_emendation_params_body, with: body
            find("*[type=submit]").click
          end
        end

        it "show previous and current step_2 highlighted" do
          within "#wizard-steps" do
            expect(page).to have_css("[aria-current]", count: 1)
            expect(page).to have_css("[aria-current]:nth-child(2)")
          end
        end

        it "shows similar emendations" do
          expect(page).to have_content("Similar Emendations (1)")

          expect(page).to have_css('[id^="proposals__proposal"]', text: "More sidewalks and less roads")
          expect(page).to have_css('[id^="proposals__proposal"]', count: 1)

          within "[data-alert-box].success" do
            expect(page).to have_content("Amendment draft has been created successfully.")
          end
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
          within ".new_amendment" do
            fill_in :amendment_emendation_params_title, with: title
            fill_in :amendment_emendation_params_body, with: body
            find("*[type=submit]").click
          end
        end

        it "redirects to step_3: Complete your amendment" do
          expect(page).to have_content("Edit Amendment Draft")
        end

        it "shows no similar proposal found callout" do
          within "[data-alert-box].success" do
            expect(page).to have_content("No similar emendations found.")
          end
        end
      end
    end

    context "and in step_3: Complete" do
      before do
        within ".new_amendment" do
          fill_in :amendment_emendation_params_title, with: title
          fill_in :amendment_emendation_params_body, with: body
          find("*[type=submit]").click
        end
      end

      it "show previous and current step_3 highlighted" do
        within "#wizard-steps" do
          expect(page).to have_css("[aria-current]", count: 1)
          expect(page).to have_css("[aria-current]:nth-child(3)")
        end
      end

      it "shows the edit amendment form" do
        expect(page).to have_content("Edit Amendment Draft")

        within ".edit_amendment" do
          fill_in :amendment_emendation_params_title, with: "#{title}Edited"
          fill_in :amendment_emendation_params_body, with: body
          find("*[type=submit]").click
        end

        within "[data-alert-box].success" do
          expect(page).to have_content("Amendment draft successfully updated.")
        end
      end

      context "when the 'Discard this draft' link is clicked" do
        before do
          within ".edit_amendment" do
            click_link "Discard this draft"
          end
        end

        it "redirects to step_1: Create your amendment" do
          within "[data-alert-box].success" do
            expect(page).to have_content("Amendment draft was successfully deleted.")
          end

          expect(page).to have_content("Create Amendment Draft")
        end
      end

      context "when the back button is clicked" do
        context "with similar results" do
          let!(:emendation) { create(:proposal, title: { en: title }, body: { en: body }, component:) }
          let!(:amendment) { create(:amendment, amendable: proposal, emendation:) }

          before do
            click_link "Back"
          end

          it "shows similar emendations" do
            expect(page).to have_content("Similar Emendations (1)")
          end
        end

        context "without similar results" do
          before do
            click_link "Back"
          end

          it "redirects to step_3: Complete your amendment" do
            expect(page).to have_content("Edit Amendment Draft")

            within "[data-alert-box].success" do
              expect(page).to have_content("No similar emendations found.")
            end
          end
        end
      end
    end

    context "and in step_4: Publish your amendment" do
      before do
        within ".new_amendment" do
          fill_in :amendment_emendation_params_title, with: title
          fill_in :amendment_emendation_params_body, with: body
          find("*[type=submit]").click
        end

        # It seems that from version 83 of chromedriver, it gets really picky
        # Content must be inside the virtual window of test
        # Got the idea from:
        # https://stackoverflow.com/a/39103252
        page.scroll_to(find(".edit_amendment"))
        within ".edit_amendment" do
          find("*[type=submit]").click
        end
      end

      it "show current step_4 highlighted" do
        within "#wizard-steps" do
          expect(page).to have_css("[aria-current]", count: 1)
          expect(page).to have_css("[aria-current]:nth-child(4)")
        end
      end

      it "shows a preview before publishing" do
        expect(page).to have_content("Publish Amendment Draft")
        expect(page).to have_content(title)
        expect(page).to have_content(user.name)
        expect(page).to have_content(body)
        expect(page).to have_button(text: "Publish")
        expect(page).to have_selector("a", text: "Modify")
      end

      context "when the Publish button is clicked", versioning: true do
        before do
          click_button "Publish"
        end

        it "publishes the amendment" do
          expect(page).to have_css(".flash.warning[data-announcement]", text: "This amendment for the proposal #{translated(proposal.title)} is being evaluated.")

          within "[data-alert-box].success" do
            expect(page).to have_content("Amendment successfully published.")
          end
        end
      end

      context "when the Modify link is clicked" do
        before do
          click_link "Modify"
        end

        it "redirects to step_3: Complete your amendment" do
          expect(page).to have_content("Edit Amendment Draft")
        end
      end

      context "when the back button is clicked" do
        before do
          click_link "Back"
        end

        it "redirects to step_3: Complete your amendment" do
          expect(page).to have_content("Edit Amendment Draft")
        end
      end
    end
  end

  context "with existing amendment drafts" do
    let!(:emendation) { create(:proposal, component:) }
    let!(:amendment) { create(:amendment, amendable: proposal, emendation:) }
    let!(:emendation_draft) { create(:proposal, :unpublished, component:) }
    let!(:amendment_draft) { create(:amendment, :draft, amendable: proposal, emendation: emendation_draft) }

    context "and visiting an amended proposal" do
      before do
        visit proposal_path
      end

      it "is NOT shown the amendment draft in the amendments list" do
        within("#amendments") do
          expect(page).to have_content("1 amendment")
        end

        within "#amendment-list" do
          expect(page).to have_content(translated(emendation.title))
          expect(page).not_to have_content(translated(emendation_draft.title))
        end
      end
    end
  end
end
