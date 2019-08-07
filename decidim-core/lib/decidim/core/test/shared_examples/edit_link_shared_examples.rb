# frozen_string_literal: true

shared_examples "editable content for admins" do
  describe "edit link" do
    before do
      relogin_as user
      visit current_path
    end

    context "when I'm an admin user" do
      let(:user) { create(:user, :admin, :confirmed, organization: organization) }

      it "has a link to edit the content at the admin" do
        within ".topbar" do
          expect(page).to have_link("Edit", href: /admin/)
        end
      end
    end

    context "when I'm a regular user" do
      let(:user) { create(:user, :confirmed, organization: organization) }

      it "does not have a link to edit the content at the admin" do
        within ".topbar" do
          expect(page).not_to have_link("Edit")
        end
      end
    end
  end
end
