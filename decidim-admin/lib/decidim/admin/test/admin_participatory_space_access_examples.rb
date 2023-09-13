# frozen_string_literal: true

shared_examples "accessing the participatory space" do
  it "shows the page" do
    expect(page).to have_content("View public page")
    expect(page).to have_content("My space")
  end
end

shared_examples "showing the unauthorized error message" do
  it "redirects to the relevant unauthorized page" do
    expect(page).to have_content("You are not authorized to perform this action")
    expect(page).to have_current_path("/admin/")
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
