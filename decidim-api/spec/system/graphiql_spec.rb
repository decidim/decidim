# frozen_string_literal: true

require "spec_helper"

describe "GraphiQL", type: :system do
  let!(:organization) { create(:organization) }

  let!(:participatory_process) do
    create(:participatory_process, organization: organization)
  end

  before do
    switch_to_host(organization.host)
    visit decidim_api.graphiql_path
  end

  context "when the organization has private access" do
    let(:organization) do
      create(
        :organization,
        force_users_to_authenticate_before_access_organization: true
      )
    end

    it "forces the user to login" do
      expect(page).to have_current_path("/users/sign_in")
      expect(page).to have_content("Please, login with your account before access")
    end
  end

  it "is able to execute the default query" do
    # Wait for the page to finish loading and the GraphiQL interface to start
    # before clicking the button for it to actually work.
    expect(page).to have_content("participatoryProcesses {")
    expect(page).not_to have_content("Loading...")
    find(".execute-button").click
    within ".result-window" do
      expect(page).to have_content("\"id\": \"#{participatory_process.id}\"")
    end
  end
end
