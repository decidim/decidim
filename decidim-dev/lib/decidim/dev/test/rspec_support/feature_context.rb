# frozen_string_literal: true
RSpec.shared_context "feature" do
  let!(:manifest_name) { raise NotImplementedError }
  let(:manifest) { Decidim.find_feature_manifest(manifest_name) }

  let!(:organization) { create(:organization) }

  let(:participatory_process) do
    create(:participatory_process, :with_steps, organization: organization)
  end

  let!(:feature) do
    create(:feature,
           manifest: manifest,
           participatory_process: participatory_process)
  end

  before do
    switch_to_host(organization.host)
  end

  def visit_feature
    page.visit decidim.feature_path(participatory_process, feature)
  end
end

RSpec.shared_context "feature admin" do
  include_context "feature"
  let(:user) { create(:user, :confirmed, organization: organization) }

  before do
    Decidim::Admin::ParticipatoryProcessUserRole.create!(
      role: :admin,
      user: user,
      participatory_process: participatory_process
    )

    login_as user, scope: :user
  end

  def visit_feature_admin
    visit decidim_admin.manage_feature_path(participatory_process, feature)
  end
end
