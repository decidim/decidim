# frozen_string_literal: true

shared_examples "cancel sortitions" do
  describe "cancellation" do
    let!(:sortition) { create(:sortition, component: current_component) }

    before do
      visit_component_admin
      click_link "Cancel the sortition"
    end

    it "requires cancellation reason" do
      within "form" do
        expect(page).to have_content(/Cancel reason/i)
      end
    end

    context "when cancels a sortition" do
      it "Redirects to sortitions view" do
        within ".confirm_destroy_sortition" do
          fill_in_i18n_editor(
            :sortition_cancel_reason,
            "#sortition-cancel_reason-tabs",
            en: "Cancel reason",
            es: "Mótivo de cancelación",
            ca: "Motiu de cancelació"
          )

          accept_confirm { find("*[type=submit]").click }
        end

        expect(page).to have_admin_callout("successfully")
      end
    end
  end
end
