# frozen_string_literal: true

require "spec_helper"

describe "Accountability component" do # rubocop:disable RSpec/DescribeClass
  let!(:component) { create(:accountability_component) }
  let(:organization) { component.organization }
  let!(:current_user) { create(:user, :confirmed, :admin, organization:) }

  describe "on edit", type: :system do
    let(:edit_component_path) do
      Decidim::EngineRouter.admin_proxy(component.participatory_space).edit_component_path(component.id)
    end

    before do
      switch_to_host(organization.host)
      login_as current_user, scope: :user
    end

    context "when comments_max_length is empty" do
      it_behaves_like "has mandatory config setting", :comments_max_length
    end
  end
end
