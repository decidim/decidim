# frozen_string_literal: true

require "spec_helper"

require "decidim/admin/test/admin_participatory_space_access_examples"

describe "AdminAccess", type: :system do
  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, organization: organization, title: { en: "My space" }) }
  let(:other_participatory_space) { create(:participatory_process, organization: organization) }

  context "with participatory space admin" do
    let(:role) { create(:process_admin, :confirmed, organization: organization, participatory_process: participatory_space) }
    let(:target_path) { decidim_admin_participatory_processes.edit_participatory_process_path(participatory_space) }
    let(:unauthorized_target_path) { decidim_admin_participatory_processes.edit_participatory_process_path(other_participatory_space) }

    it_behaves_like "admin participatory space access"
  end

  context "with participatory space valuator" do
    let(:role) { create(:process_valuator, :confirmed, participatory_process: participatory_space) }
    let(:target_path) { decidim_admin_participatory_processes.components_path(participatory_space) }
    let(:unauthorized_target_path) { decidim_admin_participatory_processes.components_path(other_participatory_space) }

    it_behaves_like "admin participatory space access"
  end

  context "with participatory space moderator" do
    let(:role) { create(:process_moderator, :confirmed, participatory_process: participatory_space) }
    let(:target_path) { decidim_admin_participatory_processes.moderations_path(participatory_space) }
    let(:unauthorized_target_path) { decidim_admin_participatory_processes.moderations_path(other_participatory_space) }

    it_behaves_like "admin participatory space access"
  end
end
