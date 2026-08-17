# frozen_string_literal: true

require "spec_helper"

describe "Admin manages conference soft delete" do
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:organization) { create(:organization) }
  let(:admin_resource_path) { decidim_admin_conferences.conferences_path }
  let(:trash_path) { decidim_admin_conferences.manage_trash_conferences_path }
  let(:title) { { en: "My space" } }
  let!(:resource) { create(:conference, title:, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit admin_resource_path
  end

  it_behaves_like "manage soft deletable component or space", "conference"
  it_behaves_like "manage trashed resource", "conference"

  context "when a user is collaborator" do
    let!(:conference) { create(:conference, organization:) }
    let!(:user) { create(:user, :admin_terms_accepted, :confirmed, organization:) }
    let!(:collaborator_role) do
      create(:conference_user_role,
             user:,
             conference:,
             role: :collaborator)
    end

    it "does not allow collaborators to view deleted conferences" do
      expect(page).to have_text("Conferences")
      expect(page).to have_no_link("View deleted conferences", href: /.*conferences.*trash.*/)
    end
  end

  context "when a user is evaluator" do
    let!(:conference) { create(:conference, organization:) }
    let!(:user) { create(:user, :admin_terms_accepted, :confirmed, organization:) }
    let!(:evaluator_role) do
      create(:conference_user_role,
             user:,
             conference:,
             role: :evaluator)
    end

    it "does not allow evaluators to view deleted conferences" do
      expect(page).to have_text("Conferences")
      expect(page).to have_no_link("View deleted conferences", href: /.*conferences.*trash.*/)
    end
  end

  context "when a user is moderator" do
    let!(:conference) { create(:conference, organization:) }
    let!(:user) { create(:user, :admin_terms_accepted, :confirmed, organization:) }
    let!(:moderator_role) do
      create(:conference_user_role,
             user:,
             conference:,
             role: :moderator)
    end

    it "does not allow moderators to view deleted conferences" do
      expect(page).to have_text("Conferences")
      expect(page).to have_no_link("View deleted conferences", href: /.*conferences.*trash.*/)
    end
  end

  context "when a user is a space admin" do
    let!(:conference) { create(:conference, organization:) }
    let!(:user) { create(:user, :admin_terms_accepted, :confirmed, organization:) }
    let!(:admin_role) do
      create(:conference_user_role,
             user:,
             conference:,
             role: :admin)
    end

    it "does not allow space admins to view deleted conferences" do
      expect(page).to have_text("Conferences")
      expect(page).to have_no_link("View deleted conferences", href: /.*conferences.*trash.*/)
    end
  end
end
