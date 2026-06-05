# frozen_string_literal: true

require "spec_helper"

describe "Admin filters assemblies members" do
  include_context "with filterable context"

  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:assembly) { create(:assembly, organization:, has_members: true) }

  let!(:invited_user1) { create(:user, name:, organization:, invitation_sent_at: 1.day.ago, invitation_accepted_at: Time.current) }
  let!(:invited_member1) { create(:assembly_member, user: invited_user1, participatory_space: assembly) }
  let!(:invited_user2) { create(:user, email:, organization:) }
  let!(:invited_member2) { create(:assembly_member, user: invited_user2, participatory_space: assembly) }

  let(:name) { "Dummy Name" }
  let(:email) { "dummy_email@example.org" }

  let(:resource_controller) { Decidim::Assemblies::Admin::MembersController }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_assemblies.members_path(assembly_slug: assembly.slug)
  end

  context "when managing assembly with members" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_assemblies.edit_assembly_path(assembly)
      within_admin_sidebar_menu do
        click_on "Members"
      end
    end

    include_examples "filterable participatory space users"
    include_examples "searchable participatory space users"
  end

  context "when trying to manage members and the space does not have members" do
    let(:assembly) { create(:assembly, organization:, has_members: false) }

    it "restricts access" do
      expect(page).to have_callout("You are not authorized to perform this action.")
    end
  end

  describe "when publishing all members" do
    let!(:member) { create(:member, :unpublished, user:, participatory_space: assembly) }

    it "publishes all members" do
      click_on "Publish all"

      sleep(1)
      expect(member.reload).to be_published
    end

    it "displays the correct log message" do
      click_on "Publish all"
      sleep(1)
      visit decidim_admin.root_path
      expect(page).to have_text("published all members of the #{translated(assembly.title)} assembly")
    end
  end
end
