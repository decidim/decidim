# frozen_string_literal: true

require "spec_helper"

describe "Admin manages initiatives taxonomy filters" do
  let(:space_manifest) { "initiatives" }

  include_context "with taxonomy filters context"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_initiatives.initiative_filters_path
  end

  it_behaves_like "a taxonomy filters controller"
end
