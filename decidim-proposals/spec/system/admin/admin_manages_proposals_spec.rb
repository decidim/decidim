# frozen_string_literal: true

require "spec_helper"

describe "Admin manages proposals" do
  let(:manifest_name) { "proposals" }
  let!(:proposal) { create(:proposal, component: current_component) }
  let!(:reportables) { create_list(:proposal, 3, component: current_component) }
  let(:participatory_space_path) do
    decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
  end

  include_context "when managing a component as an admin"
  it_behaves_like "access component permissions form"

  it_behaves_like "access permissions form" do
    let!(:row_text) { translated(proposal.title) }
  end

  it_behaves_like "manage settings"
  it_behaves_like "manage taxonomy filters in settings"
  it_behaves_like "manage proposals"
  it_behaves_like "manage moderations"
  it_behaves_like "export proposals"
  it_behaves_like "manage announcements"
  it_behaves_like "manage proposals help texts"
  it_behaves_like "when managing proposals taxonomies as an admin"
  it_behaves_like "import proposals"
  it_behaves_like "manage proposals permissions"
  it_behaves_like "merge proposals"
  it_behaves_like "split proposals"
  it_behaves_like "publish answers"

  it_behaves_like "sorted moderations" do
    let!(:reportables) { create_list(:proposal, 27, component: current_component) }
  end

  describe "Deleted proposal modal" do
    let(:proposal_title) { translated(proposal.title) }
    let(:component_name) { translated(current_component.name) }
    let(:space_title) { translated(current_component.participatory_space.title) }
    let(:resource_type_name) { proposal.class.model_name.human.downcase }

    before do
      proposal.destroy!

      visit Decidim::EngineRouter.admin_proxy(current_component).manage_trash_proposals_path
    end

    it "shows the proposal details and link to the existing restore action" do
      expect(page).to have_css(
        "#deleted-item-modal",
        count: 1,
        visible: :all
      )

      click_on proposal_title

      expect(page).to have_css("#deleted-item-modal", visible: :visible)

      within "#deleted-item-modal" do
        expect(page).to have_text(
          I18n.t(
            "decidim.admin.manage_trash.modals.restore_title",
            resource_type: resource_type_name
          )
        )

        expect(page).to have_text(
          I18n.t("decidim.admin.manage_trash.modals.resource.details")
        )

        expect(page).to have_text(proposal_title)

        expect(page).to have_text(
          I18n.t("decidim.admin.manage_trash.modals.resource.location")
        )

        expect(page).to have_text(component_name)
        expect(page).to have_text(space_title)

        expect(page).to have_button(
          I18n.t(
            "decidim.admin.manage_trash.modals.restore_title",
            resource_type: resource_type_name
          )
        )

        restore_form = find("form.button_to")

        expected_restore_path = Decidim::EngineRouter
                                .admin_proxy(current_component)
                                .restore_proposal_path(proposal)

        expect(URI.parse(restore_form[:action]).path).to eq(expected_restore_path)

        expect(restore_form).to have_css(
          "input[name='_method'][value='patch']",
          visible: :all
        )
      end
    end
  end
end
