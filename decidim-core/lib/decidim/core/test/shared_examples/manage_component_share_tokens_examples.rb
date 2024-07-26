# frozen_string_literal: true

RSpec.shared_examples "manage component share tokens" do
  let!(:components_path) { participatory_space_engine.components_path(participatory_space) }
  let!(:component) { create(:component, participatory_space:, published_at: nil) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  def visit_share_component
    visit components_path
    click_on "Components"
    click_on "Share"
  end

  context "when visiting the share_tokens page for the component" do
    let!(:share_token) { create(:share_token, token_for: component, organization:, user:, registered_only: true) }

    before do
      visit components_path
    end

    it "has a share button that opens the share tokens admin" do
      click_on "Share"
      expect(page).to have_content("Sharing tokens for: #{translated(component.name)}")
      expect(page).to have_css("tbody tr", count: 1)
      expect(page).to have_content(share_token.token)
    end
  end

  context "when visiting the share tokens index page" do
    context "when there are no tokens" do
      let(:last_token) { Decidim::ShareToken.last }
      before do
        visit_share_component
      end

      it "displays empty message" do
        expect(page).to have_content "There are no active tokens"
      end

      it "can create a new token with default options" do
        click_on "New token"

        click_on "Create"

        expect(page).to have_content("Token created successfully")
        expect(page).to have_css("tbody tr", count: 1)
        within "tbody tr:last-child td:first-child" do
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
        click_on "New token"

        find_by_id("share_token_automatic_token_false").click
        find_by_id("share_token_no_expiration_false").click
        find_by_id("share_token_registered_only_true").click
        click_on "Create"
        expect(page).to have_content("cannot be blank", count: 2)

        fill_in "share_token_token", with: " custom token "
        fill_in "share_token_expires_at", with: 1.day.from_now, visible: :all
        click_on "Create"

        expect(page).to have_content("Token created successfully")
        expect(page).to have_css("tbody tr", count: 1)
        within "tbody tr:last-child td:first-child" do
          expect(page).to have_content("CUSTOM-TOKEN")
        end
        within "tbody tr:last-child td:nth-child(2)" do
          expect(page).to have_content(1.day.from_now.strftime("%d/%m/%Y %H:%M"))
        end
        within "tbody tr:last-child td:nth-child(3)" do
          expect(page).to have_content("Yes")
        end
      end
    end

    context "when there are tokens" do
      let!(:share_tokens) { create_list(:share_token, 3, token_for: component, organization: component.organization, registered_only: true) }

      before do
        visit_share_component
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
            expect(page).to have_content share_token.expires_at
          end
        end
      end

      it "can edit a share token" do
        within "tbody tr:first-child td:nth-child(3)" do
          expect(page).to have_content("Yes")
        end
        within ".share_tokens tbody tr:first-child" do
          click_on "Edit"
        end

        expect(page).to have_content("Edit sharing tokens for: #{translated(component.name)}")
        find_by_id("share_token_no_expiration_false").click
        find_by_id("share_token_registered_only_false").click
        click_on "Update"
        expect(page).to have_content("cannot be blank", count: 1)

        fill_in "share_token_expires_at", with: 1.day.from_now, visible: :all
        click_on "Update"

        expect(page).to have_content("Token updated successfully")
        expect(page).to have_css("tbody tr", count: 3)
        within "tbody tr:first-child td:nth-child(2)" do
          expect(page).to have_content(1.day.from_now.strftime("%d/%m/%Y %H:%M"))
        end
        within "tbody tr:first-child td:nth-child(3)" do
          expect(page).to have_content("No")
        end
      end

      it "allows copying the share link from the share token" do
        within ".share_tokens tbody tr:first-child" do
          click_on "Copy link"
          expect(page).to have_content("Copied!")
          expect(page).to have_css("[data-clipboard-copy-label]")
          expect(page).to have_css("[data-clipboard-copy-message]")
          expect(page).to have_css("[data-clipboard-content]")
        end
      end

      it "has a share link for each token" do
        urls = share_tokens.map(&:url)
        within ".share_tokens tbody tr:first-child" do
          share_window = window_opened_by { click_on "Preview" }

          within_window share_window do
            expect(urls).to include(page.current_url)
          end
        end
      end

      it "has a share button that opens the share url for the component" do
        within ".share_tokens tbody tr:first-child" do
          share_window = window_opened_by { click_on "Preview", wait: 2 }

          within_window share_window do
            expect(current_url).to include(component.share_tokens.first.url)
          end
        end
      end

      it "can delete tokens" do
        within ".share_tokens tbody tr:first-child" do
          accept_confirm { click_on "Delete" }
        end

        expect(page).to have_admin_callout("Token successfully destroyed")
        expect(page).to have_css("tbody tr", count: 2)
      end
    end

    context "when there are many pages" do
      let!(:share_tokens) { create_list(:share_token, 16, token_for: component, organization: component.organization) }

      before do
        visit_share_component
      end

      it "displays pagination" do
        expect(page).to have_css("tbody tr", count: 15)
        within '[aria-label="Pagination"]' do
          click_on "Next"
        end
        expect(page).to have_css("tbody tr", count: 1)
      end
    end
  end
end
