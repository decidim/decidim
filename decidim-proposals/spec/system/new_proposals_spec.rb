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
      let!(:draft) { create(:proposal, :draft, component: component, author: user) }

      it "redirects to edit draft" do
        click_link "New proposal"
        path = "#{main_component_path(component)}proposals/#{draft.id}/edit_draft?component_id=#{component.id}&question_slug=#{component.participatory_space.slug}"
        expect(page).to have_current_path(path)
      end
    end
  end
end
