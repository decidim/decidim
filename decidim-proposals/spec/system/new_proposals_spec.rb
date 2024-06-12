# frozen_string_literal: true

require "spec_helper"

describe "Proposals", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let!(:user) { create :user, :confirmed, organization: organization }
  let!(:component) do
    create(:proposal_component,
           :with_creation_enabled,
           manifest: manifest,
           participatory_space: participatory_process)
  end

  before do
    login_as user, scope: :user
  end

  context "when creating a new proposal" do
    before do
      login_as user, scope: :user
      visit_component
    end

    context "and draft proposal exists for current users" do
      let!(:draft) { create(:proposal, :draft, component: component, users: [user]) }

      it "redirects to edit draft" do
        click_link "New proposal"
        path = "#{main_component_path(component)}proposals/#{draft.id}/edit_draft?component_id=#{component.id}&question_slug=#{component.participatory_space.slug}"
        expect(page).to have_current_path(path)
      end
    end

    context "when rich text editor is enabled for participants" do
      before do
        organization.update(rich_text_editor_in_public_views: true)
        click_link "New proposal"
      end

      it_behaves_like "having a rich text editor", "new_proposal", "basic"

      it "has helper character counter" do
        within "form.new_proposal" do
          expect(find(".editor").sibling(".form-input-extra-before")).to have_content("At least 15 characters", count: 1)
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

          expect(page).to have_css(".form-error.is-visible", text: "There's an error in this field.")
        end

        it "displays error when title is invalid" do
          fill_in :proposal_title, with: "invalid-title"
          find_by_id("proposal_body").click

          expect(page).to have_css(".form-error.is-visible", text: "There's an error in this field")
        end
      end

      context "when focus remains on title" do
        it "does not display error when title is empty" do
          fill_in :proposal_title, with: " "
          find_by_id("proposal_title").click

          expect(page).to have_no_css(".form-error.is-visible", text: "There's an error in this field.")
        end

        it "does not display error when title is invalid" do
          fill_in :proposal_title, with: "invalid-title"
          find_by_id("proposal_title").click

          expect(page).to have_no_css(".form-error.is-visible", text: "There's an error in this field")
        end
      end
    end
  end
end
