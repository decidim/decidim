# frozen_string_literal: true

require "spec_helper"

describe "Proposals" do
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let!(:user) { create(:user, :confirmed, organization:) }
  let!(:component) do
    create(:proposal_component,
           :with_creation_enabled,
           manifest:,
           participatory_space: participatory_process,
           settings: { new_proposal_body_template: body_template })
  end
  let(:body_template) do
    { "en" => "<p>This test has <strong>many</strong> characters </p>" }
  end

  context "when the user has not logged in" do
    before do
      visit_component
    end

    shared_examples "clicking the 'New proposal' button" do |selector|
      it "clicks the 'New proposal' button, logs in and redirects to the 'New proposal' form - using #{selector}" do
        expect(page).to have_css("a[data-redirect-url='#{main_component_path(component)}/new']")
        expect(page).to have_css("a[data-dialog-open='loginModal']")

        # We cannot use the click_on method because it clicks the span and we need to click various elements in button
        find(:xpath, selector).click

        within "#loginModal" do
          fill_in "Email", with: user.email
          fill_in "Password", with: user.password
          click_on "Log in"
        end

        expect(page).to have_content "Create your proposal"
        expect(page).to have_content "Title"
        expect(page).to have_content "Body"
      end
    end

    include_examples "clicking the 'New proposal' button", "//a[span[contains(text(), 'New proposal')]]"
    include_examples "clicking the 'New proposal' button", "//a[span[contains(text(), 'New proposal')]]/span"
    include_examples "clicking the 'New proposal' button", "//a[span[contains(text(), 'New proposal')]]/*[local-name()='svg']"
  end

  context "when creating a new proposal" do
    before do
      login_as user, scope: :user
      visit_component
    end

    context "and draft proposal exists for current users" do
      let!(:draft) { create(:proposal, :draft, component:, users: [user]) }

      it "redirects to edit draft" do
        click_on "New proposal"
        path = "#{main_component_path(component)}/#{draft.id}/edit_draft?component_id=#{component.id}&question_slug=#{component.participatory_space.slug}"
        expect(page).to have_current_path(path)
      end
    end

    context "when rich text editor is enabled for participants" do
      before do
        organization.update(rich_text_editor_in_public_views: true)
        click_on "New proposal"
      end

      it_behaves_like "having a rich text editor", "new_proposal", "basic"

      it "has helper character counter" do
        within "form.new_proposal" do
          within ".editor .input-character-counter__text" do
            expect(page).to have_content("At least 15 characters", count: 1)
          end
        end
      end

      it "displays the text with rich text in the input body" do
        within "form.new_proposal" do
          within ".editor-input" do
            expect(find("p").text).to eq("This test has many characters")
            expect(find("strong").text).to eq("many")
          end
        end
      end
    end

    context "when the rich text editor is disabled for participants" do
      before do
        organization.update(rich_text_editor_in_public_views: false)
        click_on "New proposal"
      end

      it "does not displays HTML tags in the body template" do
        within "form.new_proposal" do
          expect(find_by_id("proposal_body").value).not_to include("<p>")
          expect(find_by_id("proposal_body").value).not_to include("</p>")
          expect(find_by_id("proposal_body").value).not_to include("<strong>")
          expect(find_by_id("proposal_body").value).not_to include("</strong>")
          expect(find_by_id("proposal_body").value).to have_content("This test has many characters")
        end
      end
    end

    describe "validating the form" do
      before do
        click_on "New proposal"
      end

      context "when focus shifts to body" do
        it "displays error when title is empty" do
          fill_in :proposal_title, with: " "
          find_by_id("proposal_body").click

          expect(page).to have_css(".form-error.is-visible", text: "There is an error in this field.")
        end

        it "displays error when title is invalid" do
          fill_in :proposal_title, with: "invalid-title"
          find_by_id("proposal_body").click

          expect(page).to have_css(".form-error.is-visible", text: "There is an error in this field")
        end
      end

      context "when focus remains on title" do
        it "does not display error when title is empty" do
          fill_in :proposal_title, with: " "
          find_by_id("proposal_title").click

          expect(page).to have_no_css(".form-error.is-visible", text: "There is an error in this field.")
        end

        it "does not display error when title is invalid" do
          fill_in :proposal_title, with: "invalid-title"
          find_by_id("proposal_title").click

          expect(page).to have_no_css(".form-error.is-visible", text: "There is an error in this field")
        end
      end
    end
  end
end
