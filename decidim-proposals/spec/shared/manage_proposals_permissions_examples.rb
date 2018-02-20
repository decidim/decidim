# frozen_string_literal: true

shared_examples "manage proposals permissions" do
  context "when authorization handler is Everyone" do
    before do
      feature = proposal.feature
      visit ::Decidim::EngineRouter.admin_proxy(feature.participatory_space).edit_feature_permissions_path(feature.id)
    end
    it "is possible to select Example authorization handler" do
      within ".card.withdraw-permission" do
        expect(page).to have_content("Withdraw")
        find("#feature_permissions_permissions_withdraw_authorization_handler_name").first("option").click
      end
      find("*[type=submit]").click

      expect(page).to have_admin_callout("successfully")
    end
  end
end
