# frozen_string_literal: true

require "spec_helper"

describe "Comments", type: :feature, perform_enqueued: true do
  let!(:feature) { create(:result_feature, organization: organization) }
  let!(:featurable) { feature.featurable }
  let!(:participatory_process_admin) do
    user = create(:user, :confirmed, organization: organization)
    Decidim::ParticipatoryProcessUserRole.create!(
      role: :admin,
      user: user,
      participatory_process: featurable
    )
    user
  end
  let!(:commentable) { create(:result, feature: feature) }

  let(:resource_path) { resource_locator(commentable).path }
  include_examples "comments"
end
