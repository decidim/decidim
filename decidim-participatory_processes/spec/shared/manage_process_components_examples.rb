# frozen_string_literal: true

shared_examples "manage process components" do
  let!(:participatory_process) do
    create(:participatory_process, :with_phases, organization:)
  end
  let!(:attributes) { attributes_for(:component, participatory_space: participatory_process) }

  let(:phase_id) { participatory_process.phases.first.id }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "add a component" do
    before do
      visit decidim_admin_participatory_processes.components_path(participatory_process)
    end

    context "when the process has active phases" do
      before do
        find("button[data-target=add-component-dropdown]").click

        within "#add-component-dropdown" do
          click_on "Dummy Component"
        end

        within ".item__edit-form .new_component" do
          fill_in_i18n(
            :component_name,
            "#component-name-tabs",
            **attributes[:name].except("machine_translations")
          )

          within ".global-settings" do
            fill_in_i18n_editor(
              :component_settings_dummy_global_translatable_text,
              "#global-settings-dummy_global_translatable_text-tabs",
              en: "Dummy Text"
            )
            all("input[type=checkbox]").last.click
          end

          within "#panel-phase_settings" do
            fill_in_i18n_editor(
              "component_phase_settings_#{phase_id}_dummy_phase_translatable_text",
              "#phase-#{phase_id}-settings-dummy_phase_translatable_text-tabs",
              en: "Dummy Text for Phase"
            )
            all("input[type=checkbox]").first.click
          end

          click_on "Add component"
        end
      end

      it "is successfully created" do
        expect(page).to have_callout("Component created successfully.")
        expect(page).to have_text(translated(attributes[:name]))
      end

      it "has a successful admin log" do
        visit decidim_admin.root_path
        expect(page).to have_text("created #{translated(attributes[:name])} in #{translated(participatory_process.title)}")
      end

      context "and then edit it" do
        before do
          within "tr", text: translated(attributes[:name]) do
            find("button[data-controller='dropdown']").click
            click_on "Configure"
          end
        end

        it "successfully displays initial values in the form" do
          within ".global-settings" do
            expect(all("input[type=checkbox]").last).to be_checked
          end

          within "#panel-phase_settings" do
            expect(all("input[type=checkbox]").first).to be_checked
          end
        end

        it "successfully edits it" do
          click_on "Update"

          expect(page).to have_callout("The component was updated successfully.")
        end
      end
    end

    context "when the process does not have active phases" do
      let!(:participatory_process) do
        create(:participatory_process, organization:)
      end

      before do
        find("button[data-target=add-component-dropdown]").click

        within "#add-component-dropdown" do
          click_on "Dummy Component"
        end

        within ".item__edit-form .new_component" do
          fill_in_i18n(
            :component_name,
            "#component-name-tabs",
            en: "My component",
            ca: "La meva funcionalitat",
            es: "Mi funcionalitat"
          )

          within ".global-settings" do
            fill_in_i18n_editor(
              :component_settings_dummy_global_translatable_text,
              "#global-settings-dummy_global_translatable_text-tabs",
              en: "Dummy Text"
            )
            all("input[type=checkbox]").last.click
          end

          within ".default-phase-settings" do
            fill_in_i18n_editor(
              :component_default_phase_settings_dummy_phase_translatable_text,
              "#default-phase-settings-dummy_phase_translatable_text-tabs",
              en: "Dummy Text for Phase"
            )
            all("input[type=checkbox]").first.click
          end

          click_on "Add component"
        end
      end

      it "is successfully created" do
        expect(page).to have_callout("Component created successfully.")
        expect(page).to have_text("My component")
      end

      context "and then edit it" do
        before do
          within "tr", text: "My component" do
            find("button[data-controller='dropdown']").click
            click_on "Configure"
          end
        end

        it "successfully displays initial values in the form" do
          within ".global-settings" do
            expect(all("input[type=checkbox]").last).to be_checked
          end

          within ".default-phase-settings" do
            expect(all("input[type=checkbox]").first).to be_checked
          end
        end

        it "successfully edits it" do
          click_on "Update"

          expect(page).to have_callout("The component was updated successfully.")
        end
      end
    end
  end

  describe "edit a component" do
    let(:component_name) do
      {
        en: "My component",
        ca: "La meva funcionalitat",
        es: "Mi funcionalitat"
      }
    end

    let!(:component) do
      create(
        :component,
        name: component_name,
        participatory_space: participatory_process,
        phase_settings: {
          phase_id => { dummy_phase_translatable_text: generate_localized_title }
        }
      )
    end

    before do
      visit decidim_admin_participatory_processes.components_path(participatory_process)
    end

    it "updates the component" do
      within ".component-#{component.id}" do
        find("button[data-controller='dropdown']").click
        click_on "Configure"
      end

      within ".edit_component" do
        fill_in_i18n(
          :component_name,
          "#component-name-tabs",
          **attributes[:name].except("machine_translations")
        )

        within ".global-settings" do
          all("input[type=checkbox]").last.click
        end

        within "#panel-phase_settings" do
          all("input[type=checkbox]").first.click
        end

        click_on "Update"
      end

      expect(page).to have_callout("The component was updated successfully.")
      expect(page).to have_text(translated(attributes[:name]))

      within "tr", text: translated(attributes[:name]) do
        find("button[data-controller='dropdown']").click
        click_on "Configure"
      end

      within ".global-settings" do
        expect(all("input[type=checkbox]").last).to be_checked
      end

      within "#panel-phase_settings" do
        expect(all("input[type=checkbox]").first).to be_checked
      end

      visit decidim_admin.root_path
      expect(page).to have_text("updated #{translated(attributes[:name])} in #{translated(participatory_process.title)}")
    end

    context "when the process does not have active phases" do
      before { participatory_process.phases.destroy_all }

      it "updates the default phase settings" do
        within ".component-#{component.id}" do
          find("button[data-controller='dropdown']").click
          click_on "Configure"
        end

        within ".edit_component" do
          within ".default-phase-settings" do
            all("input[type=checkbox]").first.click
          end

          click_on "Update"
        end

        expect(page).to have_callout("The component was updated successfully.")

        within "tr", text: "My component" do
          find("button[data-controller='dropdown']").click
          click_on "Configure"
        end

        within ".default-phase-settings" do
          expect(all("input[type=checkbox]").first).to be_checked
        end
      end
    end
  end

  describe "publish and unpublish a component" do
    let!(:component) do
      create(:component, participatory_space: participatory_process, published_at:, visible:)
    end

    let(:published_at) { nil }
    let(:visible) { true }

    before do
      visit decidim_admin_participatory_processes.components_path(participatory_process)
    end

    context "when the component is unpublished" do
      it "publishes the component" do
        within ".component-#{component.id}" do
          find("button[data-controller='dropdown']").click
          click_on "Publish"
        end

        expect(page).to have_callout("The component has been successfully published.")

        within ".component-#{component.id}" do
          find("button[data-controller='dropdown']").click
          expect(page).to have_css("a", text: "Hide")
        end
      end

      it "notifies its followers" do
        follower = create(:user, organization: participatory_process.organization)
        create(:follow, followable: participatory_process, user: follower)

        within ".component-#{component.id}" do
          find("button[data-controller='dropdown']").click
          click_on "Publish"
        end

        expect(page).to have_callout("The component has been successfully published.")

        expect(Decidim::EventPublisherJob).to(have_been_enqueued.with(
                                                "decidim.events.components.component_published", {
                                                  resource: component,
                                                  event_class: "Decidim::ComponentPublishedEvent",
                                                  affected_users: [],
                                                  followers: [follower],
                                                  force_send: false,
                                                  extra: {}
                                                }
                                              ))
      end
    end

    context "when the component is published" do
      let(:published_at) { Time.current }

      before do
        create(:content_block, organization:, scope_name: :participatory_process_homepage, manifest_name: :main_data, scoped_resource_id: participatory_process.id)
      end

      it "hides the component from the menu" do
        visit decidim_participatory_processes.participatory_process_path(participatory_process, locale: I18n.locale)
        expect(page).to have_text translated(component.name)
        expect(page.html).to include decidim_escape_translated(component.name).gsub("&quot;", "\"")

        visit decidim_admin_participatory_processes.components_path(participatory_process)

        within ".component-#{component.id}" do
          find("button[data-controller='dropdown']").click
          click_on "Hide"
        end

        within ".component-#{component.id}" do
          find("button[data-controller='dropdown']").click
          expect(page).to have_css("a", text: "Unpublish")
        end

        visit decidim_participatory_processes.participatory_process_path(participatory_process, locale: I18n.locale)
        expect(page).to have_no_text translated(component.name)
      end
    end

    context "when the component is hidden from the menu" do
      let(:published_at) { Time.current }
      let(:visible) { false }

      it "unpublishes the component" do
        within ".component-#{component.id}" do
          find("button[data-controller='dropdown']").click
          click_on "Unpublish"
        end

        within ".component-#{component.id}" do
          find("button[data-controller='dropdown']").click
          expect(page).to have_css("a", text: "Publish")
        end
      end
    end
  end

  describe "reorders a component" do
    let!(:component1) { create(:component, name: { en: "Component 1" }, participatory_space:) }
    let!(:component2) { create(:component, name: { en: "Component 2" }, participatory_space:) }
    let!(:component3) { create(:component, name: { en: "Component 3" }, participatory_space:) }

    before do
      visit participatory_space_components_path(participatory_space)
    end

    it "changes the order of the components" do
      expect(page.text.index("Component 1")).to be < page.text.index("Component 2")
      expect(page.text.index("Component 2")).to be < page.text.index("Component 3")

      first("td.dragging-handle").drag_to(find("tbody.draggable-table tr:last-child"))

      visit current_path

      expect(page.text.index("Component 2")).to be < page.text.index("Component 1")
      expect(page.text.index("Component 2")).to be < page.text.index("Component 3")
    end
  end

  def participatory_space
    participatory_process
  end

  describe "does not reorder components after edit" do
    let!(:component1) { create(:component, name: { en: "Component 1" }, participatory_space:) }
    let!(:component2) { create(:component, name: { en: "Component 2" }, participatory_space:) }
    let!(:component3) { create(:component, name: { en: "Component 3" }, participatory_space:) }

    before do
      visit participatory_space_components_path(participatory_space)
    end

    it "does not reorder when component updates" do
      expect(page.text.index("Component 1")).to be < page.text.index("Component 2")
      expect(page.text.index("Component 2")).to be < page.text.index("Component 3")
      within ".component-#{component1.id}" do
        find("button[data-controller='dropdown']").click
        click_on "Configure"
      end
      within ".edit_component" do
        fill_in_i18n(
          :component_name,
          "#component-name-tabs",
          **attributes[:name].except("machine_translations")
        )
        within ".global-settings" do
          all("input[type=checkbox]").last.click
        end

        within "#panel-phase_settings" do
          all("input[type=checkbox]").first.click
        end

        click_on "Update"
      end
      expect(page).to have_callout("The component was updated successfully.")
      expect(page).to have_text(translated(attributes[:name]))
      expect(page).to have_text("Component 2")
      expect(page).to have_text("Component 3")
      expect(page.text.index(translated(attributes[:name]))).to be < page.text.index("Component 2")
      expect(page.text.index("Component 2")).to be < page.text.index("Component 3")
    end
  end

  def participatory_space_components_path(participatory_space)
    decidim_admin_participatory_processes.components_path(participatory_space)
  end
end
