# frozen_string_literal: true

shared_examples "manage process categories examples" do
  let(:participatory_space) { participatory_process }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
    click_link "Categories"
  end

  it_behaves_like "manage categories examples"
end
