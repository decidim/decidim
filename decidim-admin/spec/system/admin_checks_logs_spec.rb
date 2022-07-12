# frozen_string_literal: true

require "spec_helper"

describe "Admin checks logs", type: :system do
  let(:organization) { create(:organization) }

  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let!(:action_logs) { create_list :action_log, 3, organization: organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.root_path
    click_link "Admin activity log"
  end

  it "lists all recent logs" do
    expect(page).to have_content("Admin log")

    within ".content .logs.table" do
      expect(page).to have_selector("li", count: 3)
    end
  end

  context "when filtering" do
    context "with participatory space" do
      let(:space_title) { translated(action_logs.first.participatory_space.title) }
      let(:search_term) { space_title[0..2].downcase }
      let(:autocomplete_result) { "Participatory processes - #{space_title}" }

      it "lists only logs from that participatory space" do
        within ".filters__section" do
          fill_in "participatory_space_search_0", with: search_term
          expect(page).to have_content(autocomplete_result)
          find(".autoComplete_wrapper li", text: autocomplete_result).click
          find("*[type=submit]").click
        end

        within ".content .logs.table" do
          expect(page).to have_selector("li", count: 1)
        end
      end
    end

    context "with time" do
      let!(:action_logs) do
        [].tap do |logs|
          logs << create(:action_log, created_at: Time.zone.local(2022, 6, 22, 8, 9, 10), organization: organization)
          logs << create(:action_log, created_at: Time.zone.local(2022, 6, 22, 9, 10, 11), organization: organization)
          logs << create(:action_log, created_at: Time.zone.local(2022, 6, 22, 10, 11, 12), organization: organization)
        end
      end

      it "lists only logs after the start time or at the same minute" do
        within ".filters__section" do
          fill_in_datetime(:q_created_at_dtgteq, Time.zone.local(2022, 6, 22, 9, 10))
          find("*[type=submit]").click
        end

        within ".content .logs.table" do
          expect(page).to have_selector("li", count: 2)
        end
      end

      it "lists only logs before the end time or at the same minute" do
        within ".filters__section" do
          fill_in_datetime(:q_created_at_dtlteq, Time.zone.local(2022, 6, 22, 9, 10))
          find("*[type=submit]").click
        end

        within ".content .logs.table" do
          expect(page).to have_selector("li", count: 2)
        end
      end

      it "lists only logs between the start time and the end time or at the same minutes" do
        within ".filters__section" do
          fill_in_datetime(:q_created_at_dtgteq, Time.zone.local(2022, 6, 22, 8, 9))
          fill_in_datetime(:q_created_at_dtlteq, Time.zone.local(2022, 6, 22, 9, 10))
          find("*[type=submit]").click
        end

        within ".content .logs.table" do
          expect(page).to have_selector("li", count: 2)
        end
      end
    end

    context "with user" do
      let(:admin1) { create(:user, :admin, organization: organization, name: "John Doe", nickname: "joe", email: "jdoe@example.org") }
      let(:admin2) { create(:user, :admin, organization: organization, name: "Richard Roe", nickname: "roe", email: "rroe@example.org") }
      let(:admin3) { create(:user, :admin, organization: organization, name: "Joe Schmoe", nickname: "schmoe", email: "jschmoe@example.org") }
      let!(:action_logs) do
        [].tap do |logs|
          logs << create(:action_log, user: admin1, organization: organization)
          logs << create(:action_log, user: admin2, organization: organization)
          logs << create(:action_log, user: admin3, organization: organization)
        end
      end

      it "lists only logs matching the user's name" do
        within ".filters__section" do
          fill_in(:q_user_name_or_user_nickname_or_user_email_cont, with: "john")
          find("*[type=submit]").click
        end

        within ".content .logs.table" do
          expect(page).to have_selector("li", count: 1)
        end

        within ".filters__section" do
          fill_in(:q_user_name_or_user_nickname_or_user_email_cont, with: "doe")
          find("*[type=submit]").click
        end

        within ".content .logs.table" do
          expect(page).to have_selector("li", count: 1)
        end
      end

      it "lists only logs matching the user's nickname" do
        within ".filters__section" do
          fill_in(:q_user_name_or_user_nickname_or_user_email_cont, with: "schmoe")
          find("*[type=submit]").click
        end

        within ".content .logs.table" do
          expect(page).to have_selector("li", count: 1)
        end
      end

      it "lists only logs matching the user's email" do
        within ".filters__section" do
          fill_in(:q_user_name_or_user_nickname_or_user_email_cont, with: "rroe@example.org")
          find("*[type=submit]").click
        end

        within ".content .logs.table" do
          expect(page).to have_selector("li", count: 1)
        end
      end
    end
  end
end
