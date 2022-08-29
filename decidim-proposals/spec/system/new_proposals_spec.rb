# frozen_string_literal: true

require "spec_helper"

describe "Proposals", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let!(:user) { create :user, :confirmed, organization: }
  let!(:component) do
    create(:proposal_component,
           :with_creation_enabled,
           manifest:,
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
      let!(:draft) { create(:proposal, :draft, component:, users: [user]) }

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
  end
end
