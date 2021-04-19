# frozen_string_literal: true

require "spec_helper"

describe "Authorized comments", type: :system do
  let!(:component) { create(:proposal_component, organization: organization) }
  let(:authorization_handler_name) { "dummy_authorization_handler" }
  let(:authorization_handlers) do
    {
      authorization_handlers: {
        authorization_handler_name => { "options" => {} }
      }
    }
  end
  let(:comment_permission) { { comment: authorization_handlers } }
  let(:vote_comment_permission) { { vote_comment: authorization_handlers }}
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
    organization.available_authorizations = [authorization_handler_name]
    organization.save!
    sign_in user
  end

  context "when the proposal requires permissions to comment" do
    before do
      commentable.create_resource_permission(permissions: comment_permission)
      visit resource_path
    end

    it "shows a modal with a warning message" do
      expect(page).to have_content("You need to be verified to comment at this moment")
    end
  end

  context "when the proposal requires permissions to vote a comment" do
    before do
      commentable.create_resource_permission(permissions: vote_comment_permission)
      visit resource_path
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
