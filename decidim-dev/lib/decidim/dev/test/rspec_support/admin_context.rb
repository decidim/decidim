# frozen_string_literal: true

RSpec.shared_context "admin" do
  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization: organization) }

  let(:process_admin) do
    create :user,
           :process_admin,
           :confirmed,
           organization: organization,
           participatory_process: participatory_process
  end

  let(:current_feature) { create :feature, participatory_process: participatory_process, manifest_name: manifest_name }
  let!(:dummy) { create :dummy_resource, feature: current_feature }
  let!(:category) { create :category, participatory_process: participatory_process }
  let!(:scope) { create :scope, organization: organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.manage_feature_path(participatory_process_id: participatory_process, feature_id: current_feature)
  end
end
