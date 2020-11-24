# frozen_string_literal: true

require "spec_helper"

describe "Comments", type: :system do
  let!(:component) { create(:proposal_component, organization: organization) }
  let!(:author) { create(:user, :confirmed, organization: organization) }
  let!(:commentable) { create(:proposal, component: component, users: [author]) }
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let!(:comments) { create_list(:comment, 3, commentable: commentable) }

  let(:resource_path) { resource_locator(commentable).path }

  after do
    expect_no_js_errors
  end

  before do
    switch_to_host(organization.host)
  end

  include_examples "comments"

  context "when the proposal requires permissions to vote a comment" do
    before do
      organization.available_authorizations = ["dummy_authorization_handler"]
      organization.save!
      commentable.create_resource_permission(permissions: permissions)
      sign_in user
      visit resource_path
    end

    let(:permissions) do
      {
        vote_comment: {
          authorization_handlers: {
            "dummy_authorization_handler" => { "options" => {} }
          }
        }
      }
    end

    it "shows a modal with a warning message" do
      allow(commentable).to receive(:comments_have_votes?).and_return(true)

      within "#comment_#{comments[0].id}" do
        page.find(".comment__votes--up").click
      end

      expect(page).to have_selector(".comment__votes--up", text: /0/)
      expect(page).to have_content("Authorization required")
    end
  end
end
