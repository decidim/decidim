# frozen_string_literal: true

require "spec_helper"

describe "Conference moderator manages conference moderations", type: :system do
  include_context "when conference moderator administrating an conference"

  let(:current_component) { create :component, participatory_space: conference }
  let!(:reportables) { create_list(:dummy_resource, 2, component: current_component) }
  let(:participatory_space_path) do
    decidim_admin_conferences.moderations_path(conference)
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it_behaves_like "manage moderations"
end
