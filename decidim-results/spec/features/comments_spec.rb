# frozen_string_literal: true

require "spec_helper"

describe "Comments", type: :feature, perform_enqueued: true do
  let!(:feature) { create(:result_feature, organization: organization) }
  let!(:participatory_process) { feature.participatory_process }
  let!(:participatory_process_admin) do
    user = create(:user, :confirmed, organization: organization)
    Decidim::ParticipatoryProcessUserRole.create!(
      role: :admin,
      user: user,
      participatory_process: participatory_process
    )
    user
  end
  let!(:commentable) { create(:result, feature: feature) }

  let(:resource_path) { resource_locator(commentable).path }
  include_examples "comments"
end
