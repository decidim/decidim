# frozen_string_literal: true

require "spec_helper"

describe "AdminAccess", type: :system do
  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:conference, organization:, title: { en: "My space" }) }
  let(:other_participatory_space) { create(:conference, organization:) }

  context "with participatory space admin" do
    let(:role) { create(:conference_admin, :confirmed, organization:, conference: participatory_space) }
    let(:target_path) { decidim_admin_conferences.edit_conference_path(participatory_space) }
    let(:unauthorized_target_path) { decidim_admin_conferences.edit_conference_path(other_participatory_space) }

    it_behaves_like "admin participatory space access"
  end

  context "with participatory space valuator" do
    let(:role) { create(:conference_valuator, :confirmed, organization:, conference: participatory_space) }
    let(:target_path) { decidim_admin_conferences.components_path(participatory_space) }
    let(:unauthorized_target_path) { decidim_admin_conferences.components_path(other_participatory_space) }

    it_behaves_like "admin participatory space access"
  end
end
