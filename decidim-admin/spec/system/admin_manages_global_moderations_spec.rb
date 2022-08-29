# frozen_string_literal: true

require "spec_helper"

describe "Admin manages global moderations", type: :system do
  let!(:user) do
    create(
      :user,
      :confirmed,
      :admin,
      organization:
    )
  end
  let(:organization) { current_component.organization }
  let(:current_component) { create :component }
  let!(:reportables) { create_list(:dummy_resource, 2, component: current_component) }
  let(:participatory_space_path) do
    decidim_admin.moderations_path
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it_behaves_like "manage moderations" do
    let(:moderations_link_text) { "Global moderations" }
  end

  it_behaves_like "sorted moderations" do
    let!(:reportables) { create_list(:dummy_resource, 17, component: current_component) }
    let(:moderations_link_text) { "Global moderations" }
  end
end
