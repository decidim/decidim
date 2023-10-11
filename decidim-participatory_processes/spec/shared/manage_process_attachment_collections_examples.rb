# frozen_string_literal: true

shared_examples "manage process attachment collections examples" do
  let(:collection_for) { participatory_process }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
    within_admin_menu do
      click_link "Folders"
    end
  end

  it_behaves_like "manage attachment collections examples"
end
