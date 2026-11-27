# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process components" do
  include_context "when admin administrating a participatory process"

  it_behaves_like "manage process components"

  describe "Move to trash" do
    let(:admin_resource_path) { decidim_admin_participatory_processes.components_path(participatory_process) }
    let(:trash_path) { decidim_admin_participatory_processes.manage_trash_components_path(participatory_process) }
    let(:title) { { en: "My component" } }
    let!(:resource) { create(:component, manifest_name: "proposals", participatory_space: participatory_process, name: title) }

    it_behaves_like "manage soft deletable component or space", "component"
    it_behaves_like "manage trashed resource", "component"

    context "when opening the restore modal" do
      let(:component_type_name) do
        I18n.t(
          "labels.component",
          scope: "decidim.admin.manage_trash.modals"
        ).downcase
      end

      let!(:proposals) do
        create_list(
          :proposal,
          6,
          component: resource
        )
      end

      before do
        switch_to_host(organization.host)
        login_as user, scope: :user

        resource.destroy!
        visit trash_path

        expect(page).to have_css(
          "#deleted-item-modal",
          count: 1,
          visible: :all
        )

        click_on title[:en]

        expect(page).to have_css("#deleted-item-modal", visible: :visible)
      end

      it "displays the correct component information" do
        within "#deleted-item-modal" do
          expect(page).to have_text(
            I18n.t(
              "decidim.admin.manage_trash.modals.restore_title",
              resource_type: component_type_name
            )
          )

          expect(page).to have_text(
            I18n.t("decidim.admin.manage_trash.modals.component.details")
          )

          expect(page).to have_text(title[:en])

          expect(page).to have_text(
            I18n.t("decidim.components.proposals.name")
          )

          expect(page).to have_text(
            translated(participatory_process.title)
          )
        end
      end

      it "displays the affected resources" do
        within "#deleted-item-modal" do
          expect(page).to have_text(
            I18n.t(
              "decidim.admin.manage_trash.modals.component.resources_to_restore",
              resource_type: resource.manifest.name.to_s.humanize
            )
          )

          proposals.first(5).each do |proposal|
            expect(page).to have_text("##{proposal.id}")
            expect(page).to have_text(translated(proposal.title))
          end

          expect(page).to have_no_text(
            translated(proposals.last.title)
          )

          expect(page).to have_text(
            I18n.t(
              "decidim.admin.manage_trash.modals.component.showing_resources",
              displayed_count: 5,
              total_count: 6,
              remaining_count: 1
            )
          )
        end
      end

      it "links the restore button to the existing restore action" do
        within "#deleted-item-modal" do
          restore_button_text = I18n.t(
            "decidim.admin.manage_trash.modals.restore_title",
            resource_type: component_type_name
          )

          expect(page).to have_button(restore_button_text)

          restore_form = find("form.button_to")
          expected_restore_path =
            Decidim::EngineRouter
            .admin_proxy(participatory_process)
            .restore_component_path(resource)

          expect(URI.parse(restore_form[:action]).path).to eq(expected_restore_path)

          expect(restore_form).to have_css(
            "input[name='_method'][value='patch']",
            visible: :all
          )
        end
      end
    end
  end
end
