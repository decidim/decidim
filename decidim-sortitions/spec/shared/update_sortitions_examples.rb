# frozen_string_literal: true

shared_examples "update sortitions" do
  describe "update sortition data" do
    let!(:sortition) { create(:sortition, component: current_component) }
    let(:attributes) { attributes_for(:sortition, component: current_component) }

    before do
      visit_component_admin
      within "tr", text: decidim_escape_translated(sortition.title) do
        find("button[data-component='dropdown']").click
        click_on "Edit"
      end
    end

    it_behaves_like "having a rich text editor for field", ".tabs-content[data-tabs-content='sortition-additional_info-tabs']", "full"

    it "requires title" do
      within "form" do
        expect(page).to have_content(/Title/i)
      end
    end

    it "requires additional information" do
      within "form" do
        expect(page).to have_content(/Sortition information/i)
      end
    end

    context "when updates a sortition" do
      it "Redirects to sortitions view", versioning: true do
        within ".edit_sortition" do
          fill_in_i18n_editor(:sortition_additional_info, "#sortition-additional_info-tabs", **attributes[:additional_info].except("machine_translations"))
          fill_in_i18n(:sortition_title, "#sortition-title-tabs", **attributes[:title].except("machine_translations"))

          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("successfully")

        visit decidim_admin.root_path
        expect(page).to have_content("updated the #{translated(attributes[:title])} sortition")
      end
    end
  end
end
