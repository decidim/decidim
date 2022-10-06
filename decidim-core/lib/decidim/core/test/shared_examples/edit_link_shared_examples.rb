# frozen_string_literal: true

# When using these shared examples, make sure there are no prior requests within
# the same group of examples where this is included. Otherwise you may end up
# in race conditions that cause these to fail as explained at:
# https://github.com/decidim/decidim/pull/6161
shared_examples "editable content for admins" do
  describe "edit link" do
    let(:header_selector) { Decidim.redesign_active ? "header div.relative.w-full" : ".topbar" }

    before do
      relogin_as user
      visit target_path
    end

    context "when I'm an admin user" do
      let(:user) { create(:user, :admin, :confirmed, organization:) }

      it "has a link to edit the content at the admin" do
        within header_selector do
          expect(page).to have_link("Edit", href: /admin/)
        end
      end
    end

    context "when I'm a regular user" do
      let(:user) { create(:user, :confirmed, organization:) }

      it "does not have a link to edit the content at the admin" do
        within header_selector do
          expect(page).not_to have_link("Edit")
        end
      end
    end
  end
end
