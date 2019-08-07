# frozen_string_literal: true

shared_examples "manage proposals permissions" do
  context "when authorization handler is Everyone" do
    before do
      component = proposal.component
      visit ::Decidim::EngineRouter.admin_proxy(component.participatory_space).edit_component_permissions_path(component.id)
    end

    it "is possible to select Example authorization handler" do
      within ".card.withdraw-permission" do
        expect(page).to have_content("Withdraw")
        check "Example authorization (Direct)"
      end
      find("*[type=submit]").click

      expect(page).to have_admin_callout("successfully")
    end
  end
end
