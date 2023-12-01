# frozen_string_literal: true

require "spec_helper"

describe "Admin filters members" do
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
    context "when filtering Ceased" do
      it_behaves_like "a filtered collection", options: "Ceased", filter: "Ceased" do
        let(:in_filter) { member2.full_name }
        let(:not_in_filter) { member1.full_name }
      end
    end

    context "when filtering: Not ceased" do
      it_behaves_like "a filtered collection", options: "Ceased", filter: "Not ceased" do
        let(:in_filter) { member1.full_name }
        let(:not_in_filter) { member2.full_name }
      end
    end
  end

  describe "search" do
    context "when searching members without user" do
      include_examples "admin is searching participatory space users" do
        let(:value) { full_name }
      end
    end

    context "when searching members with user" do
      let(:user_name) { "Jorge Mendoza" }
      let(:user_nickname) { "mendocito" }
      let(:user) { create(:user, name: user_name, nickname: user_nickname) }
      let!(:member3) { create(:assembly_member, user:, assembly:) }

      context "when searching by name" do
        include_examples "admin is searching participatory space users" do
          let(:value) { user_name }
        end
      end

      context "when searching by nickname" do
        include_examples "admin is searching participatory space users" do
          let(:value) { user_nickname }
        end
      end
    end
  end

  it_behaves_like "paginating a collection" do
    let!(:collection) { create_list(:assembly_member, 100, assembly:) }
  end
end
