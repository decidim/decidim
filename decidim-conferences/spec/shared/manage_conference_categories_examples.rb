# frozen_string_literal: true

shared_examples "manage conference categories" do
  let(:participatory_space) { conference }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_conferences.edit_conference_path(conference)
    click_button(id: "conference-dropdown-menu-trigger")
    click_link "Categories"
  end

  it_behaves_like "manage categories examples"
end
