# frozen_string_literal: true

require "spec_helper"

describe "Admin manages conference soft delete" do
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:organization) { create(:organization) }
  let(:admin_resource_path) { decidim_admin_conferences.conferences_path }
  let(:trash_path) { decidim_admin_conferences.manage_trash_conferences_path }
  let(:title) { { en: "My space" } }
  let!(:resource) { create(:conference, title:, organization:) }

  it_behaves_like "manage soft deletable component or space", "conference"
  it_behaves_like "manage trashed resource", "conference"
end
