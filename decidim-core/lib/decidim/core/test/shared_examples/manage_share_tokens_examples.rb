# frozen_string_literal: true

shared_examples "manage resource share tokens" do
  context "when there are no tokens" do
    let(:last_token) { Decidim::ShareToken.last }
    before do
      visit_share_tokens_page
    end

    it "displays empty message" do
      expect(page).to have_content "There are no active access links"
    end

    it "can create a new token with default options" do
      click_on "New access link"

      click_on "Create"

      expect(page).to have_content("Access link created successfully")
      expect(page).to have_css("tbody tr", count: 1)
      within "tbody tr:last-child td", text: last_token.token do
        expect(page).to have_content(last_token.token)
      end
      within "tbody tr:last-child td:nth-child(2)" do
        expect(page).to have_content("Never")
      end
      within "tbody tr:last-child td:nth-child(3)" do
        expect(page).to have_content("No")
      end
    end

    it "can create a new token with custom options" do
      click_on "New access link"

      find_by_id("share_token_automatic_token_false").click
      find_by_id("share_token_no_expiration_false").click
      find_by_id("share_token_registered_only_true").click
      click_on "Create"
      expect(page).to have_content("cannot be blank", count: 2)

      fill_in "share_token_token", with: " custom token "
      fill_in_datepicker :share_token_expires_at_date, with: 1.day.from_now.strftime("%d/%m/%Y")
      fill_in_timepicker :share_token_expires_at_time, with: "00:00"
      click_on "Create"

      expect(page).to have_content("Access link created successfully")
      expect(page).to have_css("tbody tr", count: 1)
      within "tbody tr:last-child td", text: last_token.token do
        expect(page).to have_content("CUSTOM-TOKEN")
      end
      within "tbody tr:last-child td:nth-child(2)" do
        expect(page).to have_content(1.day.from_now.strftime("%d/%m/%Y 00:00"))
      end
      within "tbody tr:last-child td:nth-child(3)" do
        expect(page).to have_content("Yes")
      end
    end
  end

  context "when there are tokens" do
    let!(:share_tokens) { create_list(:share_token, 3, :with_token, token_for: resource, organization:, registered_only: true) }
    let(:last_token) { share_tokens.last }

    before do
      visit_share_tokens_page
    end

    it "displays all tokens" do
      within ".share_tokens" do
        expect(page).to have_css("tbody tr", count: 3)
      end
    end

    it "displays relevant attributes for each token" do
      share_tokens.each do |share_token|
        within ".share_tokens tbody" do
          expect(page).to have_content share_token.token
          expect(page).to have_content share_token.expires_at.to_s
        end
      end
    end

    context "when ordering" do
      let(:share_tokens) do
        [
          create(:share_token, :with_token, token_for: resource, organization:, token: "b", expires_at: 1.day.from_now, registered_only: true, times_used: 3),
          create(:share_token, :with_token, token_for: resource, organization:, token: "a", expires_at: 3.days.from_now, registered_only: true, times_used: 2),
          create(:share_token, :with_token, token_for: resource, organization:, token: "c", expires_at: 2.days.from_now, registered_only: false, times_used: 1)
        ]
      end

      it "can be ordered by token and other attributes" do
        within ".share_tokens" do
          click_on "Access link" # order by token
          expect(page).to have_css("tbody tr:first-child", text: "c")
          click_on "Access link" # order by token
          expect(page).to have_css("tbody tr:first-child", text: "a")
          click_on "Expires at" # order by expires_at
          expect(page).to have_css("tbody tr:first-child", text: share_tokens.second.expires_at.strftime("%d/%m/%Y %H:%M"))
          click_on "Expires at" # order by expires_at
          expect(page).to have_css("tbody tr:first-child", text: share_tokens.first.expires_at.strftime("%d/%m/%Y %H:%M"))
          click_on "Registered only" # order by registered_only
          expect(page).to have_css("tbody tr:first-child", text: "Yes")
          click_on "Registered only" # order by registered_only
          expect(page).to have_css("tbody tr:first-child", text: "No")
          click_on "Times used" # order by times_used
          expect(page).to have_css("tbody tr:first-child", text: "3")
          click_on "Times used" # order by times_used
          expect(page).to have_css("tbody tr:first-child", text: "1")
        end
      end
    end

    it "can edit a share token" do
      within "tbody tr", text: last_token.token do
        expect(page).to have_content("Yes")
      end
      within ".share_tokens tbody tr", text: last_token.token do
        click_on "Edit"
      end

      expect(page).to have_content("Edit access links for: #{resource_name}")
      find_by_id("share_token_no_expiration_false").click
      find_by_id("share_token_registered_only_false").click
      click_on "Update"
      expect(page).to have_content("cannot be blank", count: 1)

      fill_in_datepicker :share_token_expires_at_date, with: 1.day.from_now.strftime("%d/%m/%Y")
      fill_in_timepicker :share_token_expires_at_time, with: "00:00"

      click_on "Update"

      expect(page).to have_content("Access link updated successfully")
      expect(page).to have_css("tbody tr", count: 3)
      within "tbody tr", text: last_token.token do
        expect(page).to have_content(1.day.from_now.strftime("%d/%m/%Y 00:00"))
      end
      within "tbody tr", text: last_token.token do
        expect(page).to have_content("No")
      end
    end

    it "allows copying the share link from the share token" do
      within ".share_tokens tbody tr", text: last_token.token do
        click_on "Copy link"
        expect(page).to have_content("copied!")
        expect(page).to have_css("[data-clipboard-copy-label]")
        expect(page).to have_css("[data-clipboard-copy-message]")
        expect(page).to have_css("[data-clipboard-content]")
      end
    end

    it "has a share link for each token" do
      urls = share_tokens.map(&:url)
      within ".share_tokens tbody tr", text: last_token.token do
        share_window = window_opened_by { click_on "Preview" }

        within_window share_window do
          expect(urls).to include(page.current_url)
        end
      end
    end

    it "has a share button that opens the share url for the resource" do
      within ".share_tokens tbody tr", text: last_token.token do
        share_window = window_opened_by { click_on "Preview", wait: 2 }

        within_window share_window do
          expect(current_url).to include(last_token.url)
        end
      end
    end

    it "can delete tokens" do
      within ".share_tokens tbody tr", text: last_token.token do
        accept_confirm { click_on "Delete" }
      end

      expect(page).to have_admin_callout("Access link successfully destroyed")
      expect(page).to have_css("tbody tr", count: 2)
    end
  end

  context "when there are many pages" do
    let!(:share_tokens) { create_list(:share_token, 26, :with_token, token_for: resource, organization:) }

    before do
      visit_share_tokens_page
    end

    it "displays pagination" do
      expect(page).to have_css("tbody tr", count: 25)
      within '[aria-label="Pagination"]' do
        click_on "Next"
      end
      expect(page).to have_css("tbody tr", count: 1)
    end
  end
end

shared_examples "manage component share tokens" do
  let!(:components_path) { participatory_space_engine.components_path(participatory_space) }
  let!(:component) { create(:component, participatory_space:, published_at: nil) }
  let(:resource) { component }
  let(:resource_name) { translated(component.name) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  def visit_share_tokens_page
    visit components_path

    within("tr", text: resource_name) do
      find("button[data-component='dropdown']").click
      click_on "Access links"
    end
  end

  it_behaves_like "manage resource share tokens"
end

shared_examples "manage participatory space share tokens" do
  let(:resource) { participatory_space }
  let(:resource_name) { translated(resource.title) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  def visit_share_tokens_page
    visit participatory_spaces_path

    within("tr", text: resource_name) do
      find("button[data-component='dropdown']").click
      click_on "Access links"
    end
  end

  it_behaves_like "manage resource share tokens"
end
