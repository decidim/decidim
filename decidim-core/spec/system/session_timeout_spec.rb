# frozen_string_literal: true

require "spec_helper"

describe "Session timeout" do
  include ActiveSupport::Testing::TimeHelpers

  let(:organization) { create(:organization) }
  let(:current_user) { create(:user, :confirmed, organization:) }

  context "when session is about to timeout" do
    before do
      allow(Decidim.config).to receive(:expire_session_after).and_return(2.minutes)
      allow(Decidim.config).to receive(:session_timeout_interval).and_return(1.second)
      switch_to_host(organization.host)
      login_as current_user, scope: :user
    end

    it "timeouts if the user idles for too long" do
      visit decidim.root_path
      travel 1.minute
      expect(page).to have_text("You were inactive for too long", wait: 4)
    end

    context "with unsaved changes in an admin form" do
      let(:current_user) { create(:user, :admin, :confirmed, organization:) }

      it "timeouts if the user idles for too long with unsaved changes in a form" do
        visit decidim_admin.edit_organization_path

        page.execute_script(<<~JS)
          const input = document.querySelector("#organization_name_en");
          input.value = "Unsaved changes";
          input.dispatchEvent(new Event("input", { bubbles: true }));
        JS

        expect(page.evaluate_script(<<~JS)).to be(true)
          (() => {
            const event = new Event("beforeunload", { cancelable: true });
            window.dispatchEvent(event);
            return event.defaultPrevented;
          })()
        JS

        travel 1.minute

        20.times do
          break if page.evaluate_script("window.location.pathname").to_s.include?("/users/sign_in")

          sleep 0.5
        end

        expect(page).to have_css("#session_new_user")
      end
    end

    it "does not timeout when user is active in another window" do
      win1 = current_window
      visit decidim.root_path

      switch_to_window(open_new_window)
      visit decidim.root_path
      2.times.each do
        expect(page).to have_text("If you continue being inactive", wait: 4)
        find_by_id("continueSession").click
        travel 20.seconds
      end

      switch_to_window(win1)
      expect(page).to have_text("If you continue being inactive", wait: 4)
      find_by_id("continueSession").click
      expect(page).to have_no_text("You were inactive for too long")
    end

    it "does not timeout user who wants to be remembered" do
      current_user.remember_created_at = Time.current
      current_user.save!
      visit decidim.root_path
      travel 1.minute
      sleep 1
      expect(page).to have_no_text("You were inactive for too long")
    end
  end
end
