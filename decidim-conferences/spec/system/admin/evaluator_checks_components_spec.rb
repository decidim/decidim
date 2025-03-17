# frozen_string_literal: true

require "spec_helper"

describe "Evaluator checks components" do
  let(:current_component) { create(:component, manifest_name: "proposals", participatory_space: conference) }
  let!(:assigned_proposal) { create(:proposal, component: current_component) }
  let(:conference) { create(:conference, organization:) }
  let(:participatory_space_path) do
    decidim_admin_conferences.components_path(conference)
  end
  let(:components_path) { participatory_space_path }
  let!(:user) { create(:user, :confirmed, :admin_terms_accepted, admin: false, organization:) }
  let!(:evaluator_role) { create(:conference_user_role, role: :evaluator, user:, conference:) }
  let(:another_component) { create(:component, participatory_space: conference) }

  include Decidim::ComponentPathHelper

  include_context "when administrating a conference"

  before do
    create(:evaluation_assignment, proposal: assigned_proposal, evaluator_role:)

    switch_to_host(organization.host)
    login_as user, scope: :user
    visit components_path
  end

  it_behaves_like "needs admin TOS accepted" do
    let(:user) { create(:user, :confirmed, organization:) }
  end

  context "when listing components in the space components page" do
    it "can only see the proposals component" do
      within_admin_sidebar_menu do
        click_on "Components"
      end

      within ".card" do
        expect(page).to have_content(translated(current_component.name))
        expect(page).to have_no_content(translated(another_component.name))
      end
    end
  end

  context "when visiting the admin" do
    before do
      visit decidim_admin.root_path
    end

    it "can access the participatory space" do
      click_on "Conferences"
      click_on translated(conference.title)
      expect(page).to have_link("Components")
    end
  end
end
