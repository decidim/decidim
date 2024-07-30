# frozen_string_literal: true

require "spec_helper"

describe "Admin checks conflicts" do
  let(:organization) { create(:organization) }
  let(:resource_controller) { Decidim::Admin::ConflictsController }

  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:first_conflictive_user) { create(:user, :admin, :confirmed, organization:) }
  let!(:second_conflictive_user) { create(:user, :admin, :confirmed, organization:) }

  let!(:first_user_conflicts) { create_list(:conflict, 15, current_user: first_conflictive_user) }
  let!(:second_user_conflicts) { create_list(:conflict, 15, current_user: second_conflictive_user) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.root_path
    click_on "Participants"
    click_on "Verification conflicts"
  end

  include_context "with filterable context"

  context "when listing conflicts" do
    before { visit current_path }

    it_behaves_like "paginating a collection" do
      let!(:collection) { create_list(:conflict, 50, current_user: first_conflictive_user) }
    end
  end

  context "when searching by current user name, nickname or email" do
    before { visit current_path }

    it "can be searched by name" do
      search_by_text(first_conflictive_user.name)

      expect(page).to have_content(first_conflictive_user.name)
      expect(page).not_to have_content(second_conflictive_user.name)
    end

    it "can be searched by nickname" do
      search_by_text(first_conflictive_user.nickname)

      expect(page).to have_content(first_conflictive_user.name)
      expect(page).not_to have_content(second_conflictive_user.name)
    end

    it "can be searched by email" do
      search_by_text(first_conflictive_user.email)

      expect(page).to have_content(first_conflictive_user.name)
      expect(page).not_to have_content(second_conflictive_user.name)
    end
  end
end
