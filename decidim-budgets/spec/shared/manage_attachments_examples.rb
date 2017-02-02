require "decidim/admin/test/manage_attachments_examples"

RSpec.shared_examples "manage budget attachments" do
  let(:attached_to) { budget }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.manage_feature_path(participatory_process_id: participatory_process, feature_id: current_feature)
    within find("tr", text: translated(budget.title)) do

      click_link "Attachments"
    end
  end

  it_behaves_like "manage attachments examples"
end
