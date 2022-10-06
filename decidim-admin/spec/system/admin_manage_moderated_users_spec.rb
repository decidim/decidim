# frozen_string_literal: true

require "spec_helper"
describe "Admin manages moderated users", type: :system do
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
        expect(page).not_to have_content(second_user.name)
        expect(page).not_to have_content(third_user.name)
      end

      it "can be searched by email" do
        search_by_text(first_user.email)

        expect(page).to have_content(first_user.name)
        expect(page).not_to have_content(second_user.name)
        expect(page).not_to have_content(third_user.name)
      end

      it "can be searched by name" do
        search_by_text(first_user.name)

        expect(page).to have_content(first_user.name)
        expect(page).not_to have_content(second_user.name)
        expect(page).not_to have_content(third_user.name)
      end
    end

    context "when sorting" do
      context "with report count" do
        it "sorts reported users by report count" do
          click_link "Reports count"

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
          click_link "Reports count"

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
  end
end
