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
end
