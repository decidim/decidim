# frozen_string_literal: true

require "spec_helper"
describe "Admin manages moderated users", type: :system do
  let(:organization) { create(:organization) }
  let!(:admin) { create(:user, :admin, :confirmed, organization: organization) }
  let(:model_name) { Decidim::User.model_name }
  let(:resource_controller) { Decidim::Admin::ModeratedUsersController }

  let(:first_reportable_user) { create(:user, :confirmed, organization: organization) }
  let(:second_reportable_user) { create(:user, :confirmed, organization: organization) }
  let(:third_reportable_user) { create(:user, :confirmed, organization: organization) }

  let(:first_moderation) { create(:user_moderation, user: reportable_user, report_count: 1) }
  let(:second_moderation) { create(:user_moderation, user: reportable_user, report_count: 2) }
  let(:third_moderation) { create(:user_moderation, user: reportable_user, report_count: 3) }

  let(:first_user_report) { create(:user_report, moderation: first_moderation, user: admin, reason: "spam") }
  let(:second_user_report) { create(:user_report, moderation: second_moderation, user: admin, reason: "offensive") }
  let(:third_user_report) { create(:user_report, moderation: third_moderation, user: admin, reason: "does_not_belong") }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.moderated_users_path
  end

  include_context "with filterable context"

  context "when on reported users path" do
    context "when filtering by report count" do
      it_behaves_like "a filtered collection", options: "Report count", filter: "1" do
        let(:in_filter) { first_reportable_user.name }
        let(:not_in_filter) { second_reportable_user.name }
      end

      it_behaves_like "a filtered collection", options: "Report count", filter: "2" do
        let(:in_filter) { second_reportable_user.name }
        let(:not_in_filter) { first_reportable_user.name }
      end

      it_behaves_like "a filtered collection", options: "Report count", filter: "3" do
        let(:in_filter) { second_reportable_user.name }
        let(:not_in_filter) { third_reportable_user.name }
      end
    end

    context "when filtering by report reason" do
      it_behaves_like "a filtered collection", options: "Report reason", filter: "spam" do
        let(:in_filter) { first_reportable_user.name }
        let(:not_in_filter) { second_reportable_user.name }
      end

      it_behaves_like "a filtered collection", options: "Report reason", filter: "offensive" do
        let(:in_filter) { second_reportable_user.name }
        let(:not_in_filter) { first_reportable_user.name }
      end

      it_behaves_like "a filtered collection", options: "Report reason", filter: "does not belong" do
        let(:in_filter) { second_reportable_user.name }
        let(:not_in_filter) { third_reportable_user.name }
      end
    end

    context "when searching by email, name or nickname" do
      it "can be searched by nickname" do
        search_by_text(first_reportable_user.nickname)

        expect(page).to have_content(first_reportable_user.name)
        expect(page).not_to have_content(second_reportable_user.name)
        expect(page).not_to have_content(third_reportable_user.name)
      end

      it "can be searched by email" do
        search_by_text(first_reportable_user.email)

        expect(page).to have_content(first_reportable_user.name)
        expect(page).not_to have_content(second_reportable_user.name)
        expect(page).not_to have_content(third_reportable_user.name)
      end

      it "can be searched by name" do
        search_by_text(first_reportable_user.name)

        expect(page).to have_content(first_reportable_user.name)
        expect(page).not_to have_content(second_reportable_user.name)
        expect(page).not_to have_content(third_reportable_user.name)
      end
    end

    context "when sorting" do
      context "with report count" do
        it "sorts reported users by report count" do
          click_link "Reports count"

          find "tbody:last_child" do
            byebug
            expect(all("tr").first.text).to include(first_reportable_user.name)
            expect(all("tr").last.text).to include(third_reportable_user.name)
          end
        end
      end
    end

    context "when there is a lot of reported users" do
      it_behaves_like "paginating a collection" do
        before do
          collection.each do |reportable_user|
            moderation = create(:user_moderation, user: reportable_user, report_count: 1)
            create(:user_report, moderation: moderation, user: admin, reason: "spam")
          end
        end
      end
    end
  end
end
