# frozen_string_literal: true

require "decidim/admin/test/manage_attachment_collections_examples"

shared_examples "manage process attachment collections examples" do
  let(:participatory_space) { participatory_process }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
    click_link "Collections"
  end

  it_behaves_like "manage attachment collections examples"
end
