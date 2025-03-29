# frozen_string_literal: true

require "spec_helper"

describe "GraphiQL" do
  let!(:organization) { create(:organization) }

  let!(:participatory_process) do
    create(:participatory_process, organization:)
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

    it "forces the user to log in" do
      expect(page).to have_current_path("/users/sign_in")
      expect(page).to have_content("Please, log in with your account before access")
    end
  end

  it "is able to execute the default query" do
    # Wait for the page to finish loading and the GraphiQL interface to start
    # before clicking the button for it to actually work.
    expect(page).to have_content("participatoryProcesses {")
    find(".graphiql-execute-button").click
    within ".result-window" do
      expect(page).to have_content("\"id\": \"#{participatory_process.id}\"")
    end
  end

  context "with force_api_authentication enabled" do
    before do
      allow(Decidim::Api).to receive(:force_api_authentication).and_return(true)
      visit decidim_api.graphiql_path
    end

    it "forces the user to log in" do
      expect(page).to have_current_path("/users/sign_in")
      expect(page).to have_content("Please, log in with your account before access")
    end
  end
end
