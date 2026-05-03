# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/participatory_space_members_shared_examples"

describe "Assembly members" do
  let(:assembly) { create(:assembly, :with_content_blocks, organization:, blocks_manifests:, has_members: true) }
  let(:participatory_space) { assembly }
  let(:participatory_space_homepage_path) { decidim_assemblies.assembly_path(participatory_space, locale: I18n.locale) }
  let(:members_path) { decidim_assemblies.assembly_members_path(participatory_space, locale: I18n.locale) }
  let(:unexisting_participatory_space_members_path) { decidim_assemblies.assembly_members_path(assembly_slug: 999_999_999, locale: I18n.locale) }

  it_behaves_like "participatory space members"
end
