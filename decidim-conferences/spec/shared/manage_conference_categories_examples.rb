# frozen_string_literal: true

shared_examples "manage conference categories" do
  let(:participatory_space) { conference }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_conferences.edit_conference_path(conference)
    within_admin_sidebar_menu do
      click_on "Categories"
    end
  end

  it_behaves_like "manage categories examples"
end
