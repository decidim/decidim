# coding: utf-8
# frozen_string_literal: true

require "spec_helper"

describe "Admin manages newsletters", type: :feature do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.newsletters_path
  end

  describe "create newsletter" do
    it "allows a newsletter to be created" do
    end
  end
end
