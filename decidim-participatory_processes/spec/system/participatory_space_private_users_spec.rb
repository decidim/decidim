# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/participatory_space_members_shared_examples"

describe "Participatory process members" do
  let(:participatory_process) { create(:participatory_process, :with_content_blocks, organization:, blocks_manifests:, private_space: true) }
  let(:participatory_space) { participatory_process }
  let(:participatory_space_homepage_path) { decidim_participatory_processes.participatory_process_path(participatory_space) }
  let(:members_path) { decidim_participatory_processes.participatory_process_participatory_space_private_users_path(participatory_space) }
  let(:unexisting_participatory_space_members_path) { decidim_participatory_processes.participatory_process_participatory_space_private_users_path(participatory_process_slug: 999_999_999) }

  it_behaves_like "participatory space members" do
    # Private participatory processes require a logged in member to access the
    # members page, unlike assemblies which are transparent by default.
    let(:login_as_member) { true }
  end
end
