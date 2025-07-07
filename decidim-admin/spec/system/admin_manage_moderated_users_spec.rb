# frozen_string_literal: true

require "spec_helper"
describe "Admin manages moderated users" do
  let(:organization) { create(:organization) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let(:model_name) { Decidim::User.model_name }
  let(:resource_controller) { Decidim::Admin::ModeratedUsersController }

  let!(:first_moderation) { create(:user_moderation, user: first_user, report_count: 1) }
  let!(:second_moderation) { create(:user_moderation, user: second_user, report_count: 2) }
  let!(:third_moderation) { create(:user_moderation, user: third_user, report_count: 3) }

  let!(:first_user_report) { create(:user_report, moderation: first_moderation, user: admin, reason: "spam") }
  let!(:second_user_report) { create(:user_report, moderation: second_moderation, user: admin, reason: "offensive") }
  let!(:third_user_report) { create(:user_report, moderation: third_moderation, user: admin, reason: "does_not_belong") }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
  end

  include_context "with filterable context"

  context "when on reported users path" do
    let!(:first_user) { create(:user, :confirmed, organization:) }
    let!(:second_user) { create(:user, :confirmed, organization:) }
    let!(:third_user) { create(:user, :confirmed, organization:) }

    before do
      visit decidim_admin.moderated_users_path
    end

    describe "blocking a user" do
      it "can block them" do
        within "tr", text: first_user.name do
          find("button[data-component='dropdown']").click
          click_on "Block"
        end

        fill_in "Justification", with: "Blocking this user for testing purposes."
        click_on "Block account and send justification"

        expect(page).to have_content "Participant successfully blocked"
      end
    end

    context "when the reported user is the same user" do
      let!(:first_user) { admin }

      it "cannot block itself" do
        within "tr", text: admin.name do
          find("button[data-component='dropdown']").click
          expect(page).to have_no_css(".button", text: "Block")
        end
      end
    end

    context "when filtering by report reason" do
      it_behaves_like "a filtered collection", options: "Report reason", filter: "Spam" do
        let(:in_filter) { first_user.name }
        let(:not_in_filter) { second_user.name }
      end

      it_behaves_like "a filtered collection", options: "Report reason", filter: "Offensive" do
        let(:in_filter) { second_user.name }
        let(:not_in_filter) { first_user.name }
      end

      it_behaves_like "a filtered collection", options: "Report reason", filter: "Does not belong" do
        let(:in_filter) { third_user.name }
        let(:not_in_filter) { second_user.name }
      end
    end

    context "when searching by email, name or nickname" do
      it "can be searched by nickname" do
        search_by_text(first_user.nickname)

        expect(page).to have_content(first_user.name)
        expect(page).to have_no_content(second_user.name)
        expect(page).to have_no_content(third_user.name)
      end

      it "can be searched by email" do
        search_by_text(first_user.email)

        expect(page).to have_content(first_user.name)
        expect(page).to have_no_content(second_user.name)
        expect(page).to have_no_content(third_user.name)
      end

      it "can be searched by name" do
        search_by_text(first_user.name)

        expect(page).to have_content(first_user.name)
        expect(page).to have_no_content(second_user.name)
        expect(page).to have_no_content(third_user.name)
      end
    end

    context "when sorting" do
      context "with report count" do
        it "sorts reported users by report count" do
          click_on "Reports count"

          all("tbody").last do
            expect(all("tr").first.text).to include(first_user.name)
            expect(all("tr").last.text).to include(third_user.name)
          end
        end
      end
    end

    context "when there is a lot of reported users" do
      let!(:collection) { create_list(:user, 50, :confirmed, organization:) }

      before do
        collection.each do |user|
          moderation = create(:user_moderation, user:, report_count: 1)
          create(:user_report, moderation:, user: admin, reason: "spam")
        end
      end

      it_behaves_like "a paginated collection"
    end
  end

  context "when on blocked users path" do
    let!(:first_user) { create(:user, :confirmed, :blocked, organization:) }
    let!(:second_user) { create(:user, :confirmed, :blocked, organization:) }
    let!(:third_user) { create(:user, :confirmed, :blocked, organization:) }

    before do
      visit decidim_admin.moderated_users_path(blocked: true)
    end

    it "user cannot unreport them" do
      expect(page).to have_no_css(".action-icon--unreport")
    end

    context "when filtering by report reason" do
      it_behaves_like "a filtered collection", options: "Report reason", filter: "Spam" do
        let(:in_filter) { first_user.nickname }
        let(:not_in_filter) { second_user.nickname }
      end

      it_behaves_like "a filtered collection", options: "Report reason", filter: "Offensive" do
        let(:in_filter) { second_user.nickname }
        let(:not_in_filter) { first_user.nickname }
      end

      it_behaves_like "a filtered collection", options: "Report reason", filter: "Does not belong" do
        let(:in_filter) { third_user.nickname }
        let(:not_in_filter) { second_user.nickname }
      end
    end

    context "when searching by email, name or nickname" do
      it "can be searched by nickname" do
        search_by_text(first_user.nickname)

        expect(page).to have_content(first_user.nickname)
      end

      it "can be searched by email" do
        search_by_text(first_user.email)

        expect(page).to have_content(first_user.nickname)
      end

      it "can be searched by name" do
        search_by_text(first_user.name)

        expect(page).to have_content(first_user.nickname)
      end
    end

    context "when sorting" do
      context "with report count" do
        it "sorts reported users by report count" do
          click_on "Reports count"

          all("tbody").last do
            expect(all("tr").first.text).to include(first_user.nickname)
            expect(all("tr").last.text).to include(third_user.nickname)
          end
        end
      end
    end

    context "when there is a lot of reported users" do
      let!(:collection) { create_list(:user, 50, :confirmed, :blocked, organization:) }

      before do
        collection.each do |user|
          moderation = create(:user_moderation, user:, report_count: 1)
          create(:user_report, moderation:, user: admin, reason: "spam")
        end
      end

      it_behaves_like "a paginated collection", url: true
    end

    context "when performing bulk actions" do
      let!(:first_user) { create(:user, :confirmed, organization:) }
      let!(:second_user) { create(:user, :confirmed, organization:) }
      let!(:third_user) { create(:user, :confirmed, organization:) }

      before do
        visit decidim_admin.moderated_users_path
      end

      it "blocks reported participants" do
        expect(page).to have_content("Reported participants")
        find_by_id("moderated_users_bulk").set(true)
        expect(page).to have_content("Reported participants 3")
        click_on "Actions"
        within "#js-bulk-actions-dropdown" do
          click_on "Block"
        end
        expect(page).to have_content("Block users")
        within "#js-block-moderated_users-actions" do
          click_on "Block users"
        end
        expect(page).to have_content("Justification")
        expect(page).to have_content("Block accounts and send justification")
        fill_in "Justification", with: "Blocking these users for testing purposes."
        click_on "Block accounts and send justification"
        expect(page).to have_content("Participants successfully blocked")
      end

      it "unreports reported participants" do
        expect(page).to have_content("Reported participants")
        find_by_id("moderated_users_bulk").set(true)
        expect(page).to have_content("Reported participants 3")
        click_on "Actions"
        within "#js-bulk-actions-dropdown" do
          click_on "Unreport"
        end
        expect(page).to have_content("Unreport users")
        within "#js-unreport-moderated_users-actions" do
          click_on "Unreport users"
        end
        expect(page).to have_content("Participants successfully unreported")
      end

      context "when on blocked users path" do
        let!(:first_user) { create(:user, :confirmed, :blocked, organization:) }
        let!(:second_user) { create(:user, :confirmed, :blocked, organization:) }
        let!(:third_user) { create(:user, :confirmed, :blocked, organization:) }

        before do
          visit decidim_admin.moderated_users_path
        end

        it "unblocks reported participants" do
          click_on "Blocked"
          expect(page).to have_content("Reported participants")
          find_by_id("moderated_users_bulk").set(true)
          expect(page).to have_content("Reported participants 3")
          click_on "Actions"
          within "#js-bulk-actions-dropdown" do
            click_on "Unblock"
          end
          expect(page).to have_content("Unblock users")
          within "#js-unblock-moderated_users-actions" do
            click_on "Unblock users"
          end
          expect(page).to have_content("Participants successfully unblocked")
        end
      end
    end
  end
end
