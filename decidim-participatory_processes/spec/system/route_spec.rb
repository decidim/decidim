# frozen_string_literal: true

require "spec_helper"

describe "redirect routes" do
  let!(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
  end

  context "when there is a participatory process group" do
    it "redirects old url with locale and additional params" do
      visit "/participatory_process_groups/foo-bar?locale=es"
      expect(page).to have_current_path("/es/processes_groups/foo-bar", ignore_query: true)
    end
  end

  context "when there is a participatory process" do
    it "redirects old url with missing locale" do
      visit "/processes"
      expect(page).to have_current_path("/en/processes", ignore_query: true)
    end

    it "redirects old url with locale" do
      visit "/processes?locale=es"
      expect(page).to have_current_path("/es/processes", ignore_query: true)
    end

    it "redirects user to the new url" do
      user = create(:user, :confirmed, organization:, locale: "ca")
      login_as user, scope: :user
      visit "/"

      visit "/processes"
      expect(page).to have_current_path("/ca/processes", ignore_query: true)
    end

    it "redirects user to the new url when using custom locale" do
      user = create(:user, :confirmed, organization:, locale: "ca")
      login_as user, scope: :user
      visit "/"

      visit "/processes?locale=es"
      expect(page).to have_current_path("/es/processes", ignore_query: true)
    end

    it "redirects old url with locale and additional params" do
      visit "/processes/foo-bar?locale=es"
      expect(page).to have_current_path("/es/processes/foo-bar", ignore_query: true)
    end
  end
end
