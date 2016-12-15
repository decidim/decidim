RSpec.shared_context "admin" do
  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:participatory_process) { create(:participatory_process, organization: organization) }
  let(:process_admin) { create :user, :confirmed, organization: organization }
  let(:current_feature) { create :feature, participatory_process: participatory_process, manifest_name: "meetings" }
  let!(:meeting) { create :meeting, feature: current_feature, author: user }
end
