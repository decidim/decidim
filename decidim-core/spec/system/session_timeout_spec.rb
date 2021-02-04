# frozen_string_literal: true

require "spec_helper"

describe "Session timeout", type: :system do
  let(:organization) { create(:organization) }
  let(:current_user) { create :user, organization: organization }

  context "when session is about to timeout" do
    before do
      switch_to_host(organization.host)
      login_as current_user, scope: :user
    end

    it "shows modal" do
      Devise.timeout_in = 2.minutes
      visit decidim.root_path
      expect(page).to have_content("If you continue being inactive", wait: 11)
    end

    it "timeouts if user does nothing" do
      Devise.timeout_in = 1.minute
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(Decidim::Devise::SessionsController).to receive(:current_user).and_return(current_user)
      # rubocop:enable RSpec/AnyInstance
      visit decidim.root_path
      expect(page).to have_content("You have been signed out from the service", wait: 15)
    end
  end
end
