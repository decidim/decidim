# frozen_string_literal: true

require "spec_helper"

describe "Admin manages conferences", type: :system do
  include_context "when admin administrating a conference"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_conferences.conferences_path
  end

  it_behaves_like "manage conferences"
  it_behaves_like "manage diplomas"

  describe "listing conferences" do
    let(:model_name) { conference.class.model_name }
    let(:resource_controller) { Decidim::Conferences::Admin::ConferencesController }

    it_behaves_like "filtering collection by published/unpublished"
  end
end
