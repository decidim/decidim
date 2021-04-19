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
  let(:vote_comment_permission) { { vote_comment: authorization_handlers } }
  let(:permissions) { {} }
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
    commentable.create_resource_permission(permissions: permissions)
  end

  shared_examples_for "allowed to comment" do
    it do
      expect(page).not_to have_content("You need to be verified to comment at this moment")
      expect(page).to have_selector("form.new_comment")
    end
  end

  shared_examples_for "not allowed to comment" do
    it do
      expect(page).to have_content("You need to be verified to comment at this moment")
    end
  end

  shared_examples_for "allowed to vote a comment" do
    it do
      within "#comment_#{comments[0].id}" do
        page.find(".comment__votes--up").click
      end

      expect(page).to have_selector(".comment__votes--up", text: /1/)
    end
  end

  shared_examples_for "not allowed to vote a comment" do
    it do
      within "#comment_#{comments[0].id}" do
        page.find(".comment__votes--up").click
      end

      expect(page).to have_selector(".comment__votes--up", text: /0/)
      expect(page).to have_content("Authorization required")
    end
  end

  shared_context "with restricted comment action" do
    let(:permissions) { comment_permission }
    before do
      visit resource_path
    end
  end

  shared_context "with restricted vote_comment action" do
    let(:permissions) { vote_comment_permission }
    before do
      visit resource_path
    end
  end

  shared_context "with restricted comment and vote_comment action" do
    let(:permissions) { comment_permission.merge(vote_comment_permission) }
    before do
      visit resource_path
    end
  end

  context "when the proposal has no restriction on commenting and voting comments" do
    before do
      visit resource_path
    end

    it_behaves_like "allowed to comment"
    it_behaves_like "allowed to vote a comment"
  end

  context "when the proposal has restrictions on commenting and/or voting comments" do
    context "and user is not verified" do
      include_context "with restricted comment action" do
        it_behaves_like "not allowed to comment"
        it_behaves_like "allowed to vote a comment"
      end

      include_context "with restricted vote_comment action" do
        it_behaves_like "allowed to comment"
        it_behaves_like "not allowed to vote a comment"
      end

      include_context "with restricted comment and vote_comment action" do
        it_behaves_like "not allowed to comment"
        it_behaves_like "not allowed to vote a comment"
      end
    end

    context "and user is verified" do
      let!(:authorization) { create(:authorization, user: user, name: "dummy_authorization_handler") }

      include_context "with restricted comment action" do
        it_behaves_like "allowed to comment"
        it_behaves_like "allowed to vote a comment"
      end

      include_context "with restricted vote_comment action" do
        it_behaves_like "allowed to comment"
        it_behaves_like "allowed to vote a comment"
      end

      include_context "with restricted comment and vote_comment action" do
        it_behaves_like "allowed to comment"
        it_behaves_like "allowed to vote a comment"
      end
    end
  end
end
