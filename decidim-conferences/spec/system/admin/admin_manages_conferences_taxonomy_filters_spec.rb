# frozen_string_literal: true

require "spec_helper"

describe "Admin manages conferences taxonomy filters" do
  let(:space_manifest) { "conferences" }

  include_context "with taxonomy filters context"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_conferences.conference_filters_path
  end

  it_behaves_like "a taxonomy filters controller"
end
