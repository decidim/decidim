# frozen_string_literal: true

require "spec_helper"

describe "Process admin manages accountability", type: :system do
  let(:manifest_name) { "accountability" }

  include_context "when managing an accountability feature as a process admin"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_feature_admin
  end

  describe "Process admin manages results" do
    it_behaves_like "manage results"
    it_behaves_like "export results"
  end

  describe "child results" do
    it_behaves_like "manage child results"

    before do
      click_link translated(result.title)
    end
  end

  describe "statuses" do
    it_behaves_like "manage statuses"

    before do
      click_link "Statuses"
    end
  end
end
