# frozen_string_literal: true

require "spec_helper"

describe "Authorized comments", type: :system do
  let!(:initiative_type) { create(:initiatives_type, :online_signature_enabled, organization:) }
  let!(:scoped_type) { create(:initiatives_type_scope, type: initiative_type) }
  let(:commentable) { create(:initiative, :published, author:, scoped_type:, organization:) }
  let!(:author) { create(:user, :confirmed, organization:) }
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
      expect(page).to have_no_content("You need to be verified to comment at this moment")
      expect(page).to have_selector("form.new_comment")
    end
  end

  shared_examples_for "not allowed to comment" do
    it do
      expect(page).to have_content("You need to be verified to comment at this moment")
      click_link("You need to be verified to comment at this moment")
      expect(page).to have_content("Authorization required")
      expect(page).to have_link("Authorize with \"Example authorization\"")
      click_link("Authorize with \"Example authorization\"")
      expect(page).to have_content("Verify with Example authorization")
    end
  end

  context "when the initiative has no restriction on commenting" do
    before do
      visit resource_path
    end

    it_behaves_like "allowed to comment"
  end

  context "when the initiative has restrictions on commenting" do
    let!(:resource_permission) { commentable.create_resource_permission(permissions:) }
    let(:comment_permission) do
      { comment: authorization_handlers }
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
      end
    end

    context "and user is verified" do
      let(:authorization) { create(:authorization, user:, name: "dummy_authorization_handler") }

      describe "restricted comment action" do
        let(:permissions) { comment_permission }

        it_behaves_like "allowed to comment"
      end
    end
  end
end
