# frozen_string_literal: true

require "spec_helper"
require "decidim/admin/test/manage_attachments_examples"

describe "initiative attachments", type: :system do
  describe "when managed by admin" do
    include_context "when admins initiative"

    let(:attached_to) { initiative }
    let(:attachment_collection) { create(:attachment_collection, collection_for: initiative) }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_initiatives.edit_initiative_path(initiative)
      click_link "Attachments"
    end

    it_behaves_like "manage attachments examples"
  end
end
