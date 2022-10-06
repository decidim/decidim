# frozen_string_literal: true

require "spec_helper"

describe "Authorized comments", type: :system do
  let!(:commentable) { create(:proposal, component:, users: [author]) }
  let!(:author) { create(:user, :confirmed, organization:) }
  let!(:component) { create(:proposal_component, organization:) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let!(:comments) { create_list(:comment, 3, commentable:) }
  let!(:authorization_handler_name) { "dummy_authorization_handler" }
  let!(:organization) { create(:organization, available_authorizations:) }
  let!(:available_authorizations) { [authorization_handler_name] }

  let(:resource_path) { resource_locator(commentable).path }

  after do
    expect_no_js_errors
  end

  before do
    switch_to_host(organization.host)
    sign_in user
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

  context "when the proposal has no restriction on commenting and voting comments" do
    before do
      visit resource_path
    end

    it_behaves_like "allowed to comment"
    it_behaves_like "allowed to vote a comment"
  end

  context "when the proposal has restrictions on commenting and/or voting comments" do
    let!(:resource_permission) { commentable.create_resource_permission(permissions:) }
    let(:comment_permission) do
      { comment: authorization_handlers }
    end
    let(:vote_comment_permission) do
      { vote_comment: authorization_handlers }
    end
    let(:authorization_handlers) do
      { authorization_handlers: { authorization_handler_name => { "options" => {} } } }
    end

    before do
      authorization
      visit resource_path
    end

    context "and user is not verified" do
      let(:authorization) { nil }

      describe "restricted comment action" do
        let(:permissions) { comment_permission }

        it_behaves_like "not allowed to comment"
        it_behaves_like "allowed to vote a comment"
      end

      describe "restricted vote_comment action" do
        let(:permissions) { vote_comment_permission }

        it_behaves_like "allowed to comment"
        it_behaves_like "not allowed to vote a comment"
      end

      describe "restricted comment and vote_comment action" do
        let(:permissions) { comment_permission.merge(vote_comment_permission) }

        it_behaves_like "not allowed to comment"
        it_behaves_like "not allowed to vote a comment"
      end
    end

    context "and user is verified" do
      let(:authorization) { create(:authorization, user:, name: "dummy_authorization_handler") }

      describe "restricted comment action" do
        let(:permissions) { comment_permission }

        it_behaves_like "allowed to comment"
        it_behaves_like "allowed to vote a comment"
      end

      describe "restricted vote_comment action" do
        let(:permissions) { vote_comment_permission }

        it_behaves_like "allowed to comment"
        it_behaves_like "allowed to vote a comment"
      end

      describe "restricted comment and vote_comment action" do
        let(:permissions) { comment_permission.merge(vote_comment_permission) }

        it_behaves_like "allowed to comment"
        it_behaves_like "allowed to vote a comment"
      end
    end
  end
end
