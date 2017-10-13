# frozen_string_literal: true

shared_context "feature" do
  let(:manifest) { Decidim.find_feature_manifest(manifest_name) }

  let(:user) { create :user, :confirmed, organization: organization }

  let!(:organization) { create(:organization) }

  let(:participatory_process) do
    create(:participatory_process, :with_steps, organization: organization)
  end

  let(:participatory_space) { participatory_process }

  let!(:feature) do
    create(:feature,
           manifest: manifest,
           participatory_space: participatory_space)
  end

  let!(:category) { create :category, participatory_space: participatory_process }

  let!(:scope) { create :scope, organization: organization }

  before do
    switch_to_host(organization.host)
  end

  def visit_feature
    page.visit main_feature_path(feature)
  end
end

shared_context "feature admin" do
  include_context "feature"

  let(:current_feature) { feature }

  let(:user) do
    create :user,
           :admin,
           :confirmed,
           organization: organization
  end

  before do
    login_as user, scope: :user
    visit_feature_admin
  end

  def visit_feature_admin
    visit manage_feature_path(feature)
  end

  # Returns the config path for a given feature.
  #
  # feature - the Feature we want to find the root path for.
  #
  # Returns a url.
  def edit_feature_path(feature)
    Decidim::EngineRouter.admin_proxy(feature.participatory_space).edit_feature_path(feature.id)
  end
end

shared_context "feature process admin" do
  include_context "feature admin"

  let(:user) do
    create :user,
           :process_admin,
           :confirmed,
           organization: organization,
           participatory_process: participatory_process
  end
end
