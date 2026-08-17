# frozen_string_literal: true

require "spec_helper"

describe "GraphiQL" do
  let!(:organization) { create(:organization) }

  let!(:participatory_process) do
    create(:participatory_process, organization:)
  end

  let(:force_api_authentication) { false }

  before do
    allow(Decidim::Api).to receive(:force_api_authentication).and_return(force_api_authentication)
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
      expect(page).to have_current_path decidim.new_user_session_path
      expect(page).to have_text("Please, log in with your account before access")
    end
  end

  it "is able to execute the default query" do
    # Wait for the page to finish loading and the GraphiQL interface to start
    # before clicking the button for it to actually work.
    expect(page).to have_text("participatoryProcesses {")
    find(".graphiql-execute-button").click
    within ".result-window" do
      expect(page).to have_text("\"id\": \"#{participatory_process.id}\"")
    end
  end

  context "with force_api_authentication enabled" do
    let(:force_api_authentication) { true }

    it "forces the user to log in" do
      expect(page).to have_current_path decidim.new_user_session_path
      expect(page).to have_text("Please, log in with your account before access")
    end
  end
end
