# frozen_string_literal: true

require "spec_helper"

describe "AdminAccess", type: :system do
  let(:organization) { create(:organization) }
  let(:initiative) { create(:initiative, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when the user is a normal user" do
    let(:user) { create(:user, :confirmed, organization: organization) }
    let(:unauthorized_path) { "/" }

    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_admin_initiatives.edit_initiative_path(initiative) }
    end
  end

  context "when the user is the author of the initiative" do
    let(:user) { create(:user, :confirmed, organization: organization) }
    let(:initiative) { create(:initiative, :published, author: user, organization: organization) }
    let(:unauthorized_path) { "/" }

    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_admin_initiatives.edit_initiative_path(initiative) }
    end
  end
end
