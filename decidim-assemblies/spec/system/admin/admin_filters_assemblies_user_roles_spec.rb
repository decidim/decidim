# frozen_string_literal: true

require "spec_helper"

describe "Admin filters user_roles", type: :system do
  let(:organization) { create(:organization) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let(:assembly) { create(:assembly, organization:) }

  let(:resource_controller) { Decidim::Assemblies::Admin::AssemblyUserRolesController }
  let(:name) { "Dummy Name" }
  let(:email) { "dummy_email@example.org" }

  let!(:invited_user1) { create(:assembly_valuator, name:, assembly:) }
  let!(:invited_user2) { create(:assembly_valuator, email:, assembly:) }

  before do
    invited_user2.update!(invitation_sent_at: 1.day.ago, invitation_accepted_at: Time.current, last_sign_in_at: Time.current)

    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin_assemblies.assembly_user_roles_path(assembly_slug: assembly.slug)
  end

  include_context "with filterable context"

  include_examples "filterable participatory space user roles"
  include_examples "searchable participatory space user roles"
  context "when sorting" do
    include_examples "sortable participatory space user roles" do
      let!(:collection) do
        create_list(:assembly_collaborator, 100, assembly:,
                                                 last_sign_in_at: 2.days.ago,
                                                 invitation_accepted_at: 1.day.ago)
      end
      let!(:user) do
        create(:assembly_valuator,
               name: "ZZZupper user",
               email: "zzz@example.org",
               assembly:,
               last_sign_in_at: 30.seconds.ago,
               invitation_accepted_at: Time.current)
      end

      before do
        visit decidim_admin_assemblies.assembly_user_roles_path(assembly_slug: assembly.slug, q: { s: sort_by })
      end
    end
  end

  it_behaves_like "paginating a collection" do
    let!(:collection) { create_list(:assembly_valuator, 100, assembly:) }

    before do
      switch_to_host(organization.host)
      login_as admin, scope: :user
      visit decidim_admin_assemblies.assembly_user_roles_path(assembly_slug: assembly.slug)
    end
  end
end
