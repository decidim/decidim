# frozen_string_literal: true

require "spec_helper"

describe "Show replies" do
  let!(:organization) { create(:organization) }
  let!(:component) { create(:component, manifest_name: :dummy, organization:) }
  let!(:commentable) { create(:dummy_resource, component:) }
  let!(:comment) { create(:comment, commentable:) }
  let!(:replies) { create_list(:comment, 3, commentable: comment, root_commentable: commentable) }

  let(:resource_path) { resource_locator(commentable).path }

  before do
    switch_to_host(organization.host)
    visit resource_path
  end

  after do
    expect_no_js_errors
  end

  context "when viewing a comment with replies" do
    it "shows the replies button with the correct count" do
      expect(page).to have_content("3 replies")
    end

    it "loads the replies when clicking the button", :slow do
      click_button "3 replies"

      expect(page).to have_css(".comment-thread .comment", count: 4)
    end
  end

  context "when the locale is different than English" do
    before do
      visit resource_path

      within_language_menu do
        click_on "Castellano"
      end
    end

    it "shows the replies button in the correct locale" do
      expect(page).to have_content("3 respuestas")
    end

    it "loads the replies when clicking the button in the correct locale", :slow do
      click_button "3 respuestas"

      expect(page).to have_css(".comment-thread .comment", count: 4)
    end
  end
end
