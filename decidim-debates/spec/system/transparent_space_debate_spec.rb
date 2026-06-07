# frozen_string_literal: true

require "spec_helper"

describe "Transparent Space Debate" do
  let(:manifest_name) { "debates" }
  let(:manifest) { Decidim.find_component_manifest(manifest_name) }

  let!(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }
  let!(:other_user) { create(:user, :confirmed, organization:) }
  let!(:member) { create(:member, user: other_user, participatory_space:) }

  let!(:participatory_space) { create(:assembly, :published, :transparent, organization:) }
  let!(:component) { create(:component, manifest:, participatory_space:) }

  def visit_component
    page.visit main_component_path(component)
  end

  before do
    switch_to_host(organization.host)
    component.update!(default_step_settings: { creation_enabled: true })
  end

  context "when the user is not logged in" do
    it "does not allow create a debate" do
      visit_component

      within "aside" do
        expect(page).to have_no_link("New debate")
      end
    end
  end

  context "when the user is logged in" do
    context "and is member space" do
      before do
        login_as other_user, scope: :user
      end

      it "allows creating a debate" do
        visit_component

        expect(page).to have_link("New debate")
      end
    end

    context "and is not member space" do
      before do
        login_as user, scope: :user
      end

      it "does not allow creating a debate" do
        visit_component

        within "aside" do
          expect(page).to have_no_link("New debate")
        end
      end
    end
  end
end
