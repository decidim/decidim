# frozen_string_literal: true

RSpec.shared_context "admin" do
  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:participatory_process) { create(:participatory_process, organization: organization) }
  let(:process_admin) { create :user, :confirmed, organization: organization }
  let!(:user_role) { create :participatory_process_user_role, user: process_admin, participatory_process: participatory_process }
  let(:current_feature) { create :proposal_feature, participatory_process: participatory_process }
  let!(:proposal) { create :proposal, feature: current_feature }
  let!(:category) { create :category, participatory_process: participatory_process }
  let!(:scope) { create :scope, organization: organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.manage_feature_path(participatory_process_id: participatory_process, feature_id: current_feature)
  end
end
