# frozen_string_literal: true

require "spec_helper"

describe "Admin manages results", type: :feature do
  include_context "admin"
  it_behaves_like "manage results"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_process_accountability.root_path(participatory_process_id: participatory_process, feature_id: current_feature)
  end
end

describe "Admin manages child results", type: :feature do
  include_context "admin"
  it_behaves_like "manage child results"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_process_accountability.root_path(participatory_process_id: participatory_process, feature_id: current_feature)
    click_link translated(result.title)
  end
end

describe "Admin manages statuses", type: :feature do
  include_context "admin"
  it_behaves_like "manage statuses"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_process_accountability.root_path(participatory_process_id: participatory_process, feature_id: current_feature)
    click_link "Statuses"
  end
end
