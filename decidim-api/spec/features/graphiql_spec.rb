# frozen_string_literal: true

require "spec_helper"

describe "GraphiQL", type: :feature do
  let!(:organization) { create(:organization) }

  let!(:participatory_process) do
    create(:participatory_process, organization: organization)
  end

  before do
    switch_to_host(organization.host)
    visit decidim_api.graphiql_path
  end

  it "is able to execute the default query" do
    find(".execute-button").click
    within ".result-window" do
      expect(page).to have_content("\"id\": \"#{organization.id}\"")
    end
  end
end
