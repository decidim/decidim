# frozen_string_literal: true

RSpec.shared_examples "manage component share tokens" do
  let!(:components_path) { participatory_space_components_path(participatory_space) }

  context "when visiting the components page for the participatory space" do
    before do
      visit components_path
    end

    it "has a share button that opens the share url for the component" do
      share_window = window_opened_by { click_link "Share", wait: 2 }

      within_window share_window do
        expect(page).to have_current_path(component.share_tokens.reload.last.url)
      end
    end
  end

  context "when visiting the component configuration page" do
    context "when there are tokens" do
      let!(:share_tokens) { create_list(:share_token, 3, token_for: component, organization: component.organization) }
      let!(:share_token) { share_tokens.last }

      before do
        visit components_path

        within find("tr", text: component.name["en"]) do
          click_link "Configure"
        end
      end

      it "displays all tokens" do
        within ".share_tokens" do
          expect(page).to have_selector("tbody tr", count: 3)
        end
      end

      it "displays relevant attributes for each token" do
        share_tokens.each do |share_token|
          within ".share_tokens tbody" do
            expect(page).to have_content share_token.token
            expect(page).to have_content share_token.user.name
          end
        end
      end

      it "has a share link for each token" do
        urls = share_tokens.map(&:url).map { |url| url.split("?").first }
        within ".share_tokens tbody tr:first-child" do
          share_window = window_opened_by { click_link "Share" }

          within_window share_window do
            expect(urls).to include(page.current_path)
          end
        end
      end

      it "has a link to delete tokens" do
        within ".share_tokens tbody tr:first-child" do
          accept_confirm { click_link "Delete" }
        end

        expect(page).to have_admin_callout("successfully")
        expect(page).to have_selector("tbody tr", count: 2)
      end
    end

    context "when there are no tokens" do
      before do
        visit components_path

        within find("tr", text: component.name["en"]) do
          click_link "Configure"
        end
      end

      it "displays empty message" do
        expect(page).to have_content "There are no active tokens"
      end
    end
  end
end
