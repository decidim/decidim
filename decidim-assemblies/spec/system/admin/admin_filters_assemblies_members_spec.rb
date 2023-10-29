# frozen_string_literal: true

require "spec_helper"

describe "Admin filters members", type: :system do
  let(:organization) { create(:organization) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let(:assembly) { create(:assembly, organization:) }

  let(:resource_controller) { Decidim::Assemblies::Admin::AssemblyMembersController }
  let(:full_name) { "Dummy Name" }

  let!(:member1) { create(:assembly_member, full_name:, assembly:) }
  let!(:member2) { create(:assembly_member, :ceased, assembly:) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin_assemblies.assembly_members_path(assembly_slug: assembly.slug)
  end

  include_context "with filterable context"

  context "when filtering by ceased" do
    context "when filtering by ceased" do
      include_examples "admin is filtering participatory space users", label: "Ceased", value: "Ceased" do
        let(:compare_with) { member2.full_name }
      end
    end

    context "when filtering by not ceased" do
      include_examples "admin is filtering participatory space users", label: "Ceased", value: "Not ceased" do
        let(:compare_with) { member1.full_name }
      end
    end
  end

  context "when searching by name" do
    include_examples "admin is searching participatory space users" do
      let(:value) { full_name }
    end
  end

  it_behaves_like "paginating a collection" do
    let!(:collection) { create_list(:assembly_member, 100, assembly:) }
  end
end
