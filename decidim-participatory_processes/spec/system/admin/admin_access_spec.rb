# frozen_string_literal: true

require "spec_helper"

require "decidim/admin/test/admin_participatory_space_access_examples"

describe "AdminAccess" do
  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, organization:, title: { en: "My space" }) }
  let(:other_participatory_space) { create(:participatory_process, organization:) }

  context "with participatory space admin" do
    let(:role) { create(:process_admin, :confirmed, organization:, participatory_process: participatory_space) }
    let(:target_path) { decidim_admin_participatory_processes.edit_participatory_process_path(participatory_space) }
    let(:unauthorized_target_path) { decidim_admin_participatory_processes.edit_participatory_process_path(other_participatory_space) }
    let(:participatory_space_path) { decidim_participatory_processes.participatory_process_path(participatory_space) }

    it_behaves_like "admin participatory space access"
    it_behaves_like "admin participatory space edit button"
  end

  context "with participatory space evaluator" do
    let(:role) { create(:process_evaluator, :confirmed, participatory_process: participatory_space) }
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
