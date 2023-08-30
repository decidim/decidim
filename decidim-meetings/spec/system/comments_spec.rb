# frozen_string_literal: true

require "spec_helper"

describe "Comments", type: :system do
  let!(:component) { create(:component, manifest_name: :meetings, organization:) }
  let!(:participatory_space) { component.participatory_space }
  let!(:participatory_process_admin) do
    user = create(:user, :confirmed, :admin_terms_accepted, organization:)
    Decidim::ParticipatoryProcessUserRole.create!(
      role: :admin,
      user:,
      participatory_process: participatory_space
    )
    user
  end
  let!(:commentable) { create(:meeting, :published, component:) }
  let!(:follow) { create(:follow, followable: commentable, user: participatory_process_admin) }

  let(:resource_path) { resource_locator(commentable).path }

  before do
    # Make static map requests not to fail with HTTP 500 (causes JS error)
    stub_request(:get, Regexp.new(Decidim.maps.fetch(:static).fetch(:url))).to_return(body: "")
  end

  include_examples "comments"
end
