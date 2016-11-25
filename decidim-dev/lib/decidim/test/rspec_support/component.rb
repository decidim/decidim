# frozen_string_literal: true
RSpec.shared_context "component" do
  let!(:feature_manifest) { raise NotImplementedError }
  let!(:component_manifest) { raise NotImplementedError }

  let!(:organization) { create(:organization) }

  let(:participatory_process) do
    create(:participatory_process, organization: organization)
  end

  let!(:participatory_process_step) do
    create(:participatory_process_step, participatory_process: participatory_process)
  end

  let!(:feature) do
    create(:feature,
           manifest: feature_manifest,
           participatory_process: participatory_process)
  end

  let!(:component) do
    create(:component,
           manifest: component_manifest,
           step: participatory_process_step,
           feature: feature)
  end

  before do
    switch_to_host(organization.host)
  end

  def visit_component
    visit decidim.component_path(participatory_process, component)
  end
end

RSpec.shared_context "component admin" do
  include_context "component"
  let(:user) { create(:user, :confirmed, organization: organization) }

  before do
    Decidim::Admin::ParticipatoryProcessUserRole.create!(
      role: :admin,
      user: user,
      participatory_process: participatory_process
    )

    login_as user, scope: :user
  end

  def visit_component_admin
    visit decidim_admin.manage_component_path(participatory_process, feature, component)
  end
end
