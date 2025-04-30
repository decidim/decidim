# frozen_string_literal: true

require "spec_helper"

require "decidim/admin/test/admin_participatory_space_access_examples"

describe "AdminAccess" do
  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:conference, organization:, title: { en: "My space" }) }
  let(:other_participatory_space) { create(:conference, organization:) }

  context "with participatory space admin" do
    let(:role) { create(:conference_admin, :confirmed, organization:, conference: participatory_space) }
    let(:target_path) { decidim_admin_conferences.edit_conference_path(participatory_space) }
    let(:unauthorized_target_path) { decidim_admin_conferences.edit_conference_path(other_participatory_space) }
    let(:participatory_space_path) { decidim_conferences.conference_path(participatory_space) }

    it_behaves_like "admin participatory space access"
    it_behaves_like "admin participatory space edit button"
  end

  context "with participatory space evaluator" do
    let(:role) { create(:conference_evaluator, :confirmed, organization:, conference: participatory_space) }
    let(:target_path) { decidim_admin_conferences.components_path(participatory_space) }
    let(:unauthorized_target_path) { decidim_admin_conferences.components_path(other_participatory_space) }

    it_behaves_like "admin participatory space access"
  end

  context "with participatory space moderator" do
    let(:role) { create(:conference_moderator, :confirmed, organization:, conference: participatory_space) }
    let(:target_path) { decidim_admin_conferences.moderations_path(participatory_space) }
    let(:unauthorized_target_path) { decidim_admin_conferences.moderations_path(other_participatory_space) }

    it_behaves_like "admin participatory space access"
  end
end
