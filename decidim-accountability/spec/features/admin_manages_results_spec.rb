# frozen_string_literal: true

require "spec_helper"

describe "Admin manages results", type: :feature do
  let(:manifest_name) { "accountability" }

  include_context "admin"
  include_context "feature admin"

  it_behaves_like "manage results"
  it_behaves_like "export results"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_feature_admin
  end
end

describe "Admin manages child results", type: :feature do
  let(:manifest_name) { "accountability" }

  include_context "admin"
  include_context "feature admin"

  it_behaves_like "manage child results"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_feature_admin
    click_link translated(result.title)
  end
end

describe "Admin manages statuses", type: :feature do
  let(:manifest_name) { "accountability" }

  include_context "admin"
  include_context "feature admin"

  it_behaves_like "manage statuses"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_feature_admin
    click_link "Statuses"
  end
end
