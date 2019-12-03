# frozen_string_literal: true

shared_examples "manage assembly categories" do
  let(:participatory_space) { assembly }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_assemblies.edit_assembly_path(assembly)
    click_link "Categories"
  end

  it_behaves_like "manage categories examples"
end
