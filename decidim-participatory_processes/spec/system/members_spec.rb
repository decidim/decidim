# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/participatory_space_members_shared_examples"

describe "Participatory Process members" do
  let(:participatory_process) { create(:participatory_process, :with_content_blocks, organization:, blocks_manifests:, has_members: true) }
  let(:participatory_space) { participatory_process }
  let(:participatory_space_homepage_path) { decidim_participatory_processes.participatory_process_path(participatory_space, locale: I18n.locale) }
  let(:members_path) { decidim_participatory_processes.participatory_process_members_path(participatory_space, locale: I18n.locale) }
  let(:unexisting_participatory_space_members_path) { decidim_participatory_processes.participatory_process_members_path(participatory_process_slug: 999_999_999, locale: I18n.locale) }

  it_behaves_like "participatory space members"
end
