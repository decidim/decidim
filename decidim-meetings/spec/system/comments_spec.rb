# frozen_string_literal: true

require "spec_helper"

describe "Comments", type: :system do
  let!(:component) { create(:component, manifest_name: :meetings, organization: organization) }
  let!(:participatory_space) { component.participatory_space }
  let!(:participatory_process_admin) do
    user = create(:user, :confirmed, :admin_terms_accepted, organization: organization)
    Decidim::ParticipatoryProcessUserRole.create!(
      role: :admin,
      user: user,
      participatory_process: participatory_space
    )
    user
  end
  let!(:commentable) { create(:meeting, component: component) }
  let!(:follow) { create(:follow, followable: commentable, user: participatory_process_admin) }

  let(:resource_path) { resource_locator(commentable).path }

  before do
    # Make static map requests not to fail with HTTP 500 (causes JS error)
    stub_request(:get, Regexp.new(Decidim.geocoder.fetch(:static_map_url))).to_return(body: "")
  end

  include_examples "comments"
end
