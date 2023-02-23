# frozen_string_literal: true

# rubocop:disable RSpec/EmptyExampleGroup
require "spec_helper"
describe "Report Comment", type: :system do
  let!(:organization) { create(:organization) }
  let(:user) { create :user, :confirmed, organization: }
  let(:participatory_space) { commentable }
  let(:participatory_process) { commentable }
  let!(:commentable) { create(:initiative, organization:) }
  let!(:reportable) { create(:comment, commentable:) }
  let(:reportable_path) { decidim_initiatives.initiative_path(commentable) }

  before do
    switch_to_host(organization.host)
  end

  # Redesign pending
  # Uncomment when the redesign is done in this module, otherwise tests will fail because
  # the reports old markup doesn't work with the new design and the new tests created for it.
  # include_examples "comments_reports"
end
# rubocop:enable RSpec/EmptyExampleGroup
