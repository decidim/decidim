# frozen_string_literal: true

require "spec_helper"
describe "Admin filters user_groups", type: :system do
  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:resource_controller) { Decidim::Admin::UserGroupsController }
  let(:model_name) { Decidim::UserGroup.model_name }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.user_groups_path
  end

  include_context "with filterable context"

  context "when filtering by State" do
    let!(:pending_ug) { create(:user_group, organization:, users: [user]) }
    let!(:verified_ug) { create(:user_group, :verified, organization:, users: [user]) }
    let!(:rejected_ug) { create(:user_group, :rejected, organization:, users: [user]) }

    context "when pending" do
      it_behaves_like "a filtered collection", options: "State", filter: "Pending" do
        let(:in_filter) { pending_ug.name }
        let(:not_in_filter) { verified_ug.name }
      end

      it_behaves_like "a filtered collection", options: "State", filter: "Pending" do
        let(:in_filter) { pending_ug.name }
        let(:not_in_filter) { rejected_ug.name }
      end
    end

    context "when verified" do
      it_behaves_like "a filtered collection", options: "State", filter: "Verified" do
        let(:in_filter) { verified_ug.name }
        let(:not_in_filter) { pending_ug.name }
      end

      it_behaves_like "a filtered collection", options: "State", filter: "Verified" do
        let(:in_filter) { verified_ug.name }
        let(:not_in_filter) { rejected_ug.name }
      end
    end

    context "when rejected" do
      it_behaves_like "a filtered collection", options: "State", filter: "Rejected" do
        let(:in_filter) { rejected_ug.name }
        let(:not_in_filter) { pending_ug.name }
      end

      it_behaves_like "a filtered collection", options: "State", filter: "Rejected" do
        let(:in_filter) { rejected_ug.name }
        let(:not_in_filter) { verified_ug.name }
      end
    end
  end

  context "when searching by ID or title" do
    let!(:group) { create(:user_group, organization:, users: [user]) }

    it "can be searched by nickname" do
      search_by_text(group.nickname)

      expect(page).to have_content(group.name)
    end

    it "can be searched by email" do
      search_by_text(group.email)

      expect(page).to have_content(group.name)
    end

    it "can be searched by name" do
      search_by_text(group.name)

      expect(page).to have_content(group.name)
    end
  end

  context "when sorting" do
    let!(:another_user) { create(:user, :admin, :confirmed, organization:) }
    let!(:collection) { create_list(:user_group, 50, :verified, organization:, users: [user]) }
    let!(:group) do
      create(:user_group, organization:, users: [user, another_user],
                          name: "ZZZupper group",
                          document_number: "9999999999",
                          phone: "999.999.9999").reload
    end

    context "with state desc" do
      before { visit decidim_admin.user_groups_path(q: { s: "state desc" }) }

      it "displays the result" do
        expect(page).to have_content(group.name)
      end
    end

    context "with state Asc" do
      before { visit decidim_admin.user_groups_path(q: { s: "state asc" }) }

      it "hides the result" do
        expect(page).not_to have_content(group.name)
      end
    end

    context "with participants count desc" do
      before { visit decidim_admin.user_groups_path(q: { s: "users_count desc" }) }

      it "displays the result" do
        expect(group.users.size).to eq(2)
        expect(page).to have_content(group.name)
      end
    end

    context "with participants count asc" do
      before { visit decidim_admin.user_groups_path(q: { s: "users_count asc" }) }

      it "hides the result" do
        expect(group.users.size).to eq(2)
        expect(page).not_to have_content(group.name)
      end
    end

    context "with phone desc" do
      before { visit decidim_admin.user_groups_path(q: { s: "phone desc" }) }

      it "displays the result" do
        expect(group.users.size).to eq(2)
        expect(page).to have_content(group.name)
      end
    end

    context "with phone asc" do
      before { visit decidim_admin.user_groups_path(q: { s: "phone asc" }) }

      it "hides the result" do
        expect(group.users.size).to eq(2)
        expect(page).not_to have_content(group.name)
      end
    end

    context "with document desc" do
      before { visit decidim_admin.user_groups_path(q: { s: "document_number desc" }) }

      it "displays the result" do
        expect(group.users.size).to eq(2)
        expect(page).to have_content(group.name)
      end
    end

    context "with document asc" do
      before { visit decidim_admin.user_groups_path(q: { s: "document_number asc" }) }

      it "hides the result" do
        expect(group.users.size).to eq(2)
        expect(page).not_to have_content(group.name)
      end
    end

    context "with name desc" do
      before { visit decidim_admin.user_groups_path(q: { s: "name desc" }) }

      it "displays the result" do
        expect(group.users.size).to eq(2)
        expect(page).to have_content(group.name)
      end
    end

    context "with name asc" do
      before { visit decidim_admin.user_groups_path(q: { s: "name asc" }) }

      it "hides the result" do
        expect(group.users.size).to eq(2)
        expect(page).not_to have_content(group.name)
      end
    end
  end

  it_behaves_like "paginating a collection" do
    let!(:collection) { create_list(:user_group, 50, organization:, users: [user]) }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin.user_groups_path
    end
  end
end
