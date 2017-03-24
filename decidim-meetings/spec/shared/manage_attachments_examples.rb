require "decidim/admin/test/manage_attachments_examples"

RSpec.shared_examples "manage meetings attachments" do
  let(:attached_to) { meeting }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.manage_feature_path(participatory_process_id: participatory_process, feature_id: current_feature)
    within find("tr", text: translated(meeting.title)) do

      find("a.action-icon--attachments").click
    end
  end

  it_behaves_like "manage attachments examples"
end
