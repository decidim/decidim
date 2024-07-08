# frozen_string_literal: true

shared_examples "accessing the participatory space" do
  it "shows the page" do
    # Since the button now contains dynamic text, we have to check the href
    expect(page).to have_css("[href='#{resource_locator(try(:participatory_space) || try(:participatory_process)).path.split("?").first}']", text: "See")
    expect(page).to have_content("My space")
  end
end

shared_examples "showing the unauthorized error message" do
  it "redirects to the relevant unauthorized page" do
    expect(page).to have_content("You are not authorized to perform this action")
    expect(page).to have_current_path("/admin/")
  end
end

shared_examples "admin participatory space edit button" do
  context "and visits the participatory space public page" do
    before do
      switch_to_host(organization.host)
      login_as role, scope: :user
    end

    it "shows the admin bar with the Edit button" do
      visit participatory_space_path

      within "#admin-bar" do
        expect(page).to have_link("Edit", href: target_path)
      end
    end
  end
end

shared_examples "admin participatory space access" do
  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when the user is a normal user" do
    let(:user) { create(:user, :confirmed, organization:) }
    let(:unauthorized_path) { "/" }

    it_behaves_like "a 404 page"
  end

  context "when the user has the role" do
    let(:user) { role }

    context "and visits the root path" do
      it "shows the admin bar" do
        visit decidim.root_path

        within "#admin-bar" do
          expect(page).to have_link("Admin dashboard", href: "/admin/")
        end
      end
    end

    context "and has permission" do
      before do
        visit target_path
      end

      it_behaves_like "accessing the participatory space"
    end

    context "and does not have permission" do
      before do
        visit unauthorized_target_path
      end

      it_behaves_like "showing the unauthorized error message"
    end
  end
end
