# frozen_string_literal: true

shared_examples "manage process components" do
  let!(:participatory_process) do
    create(:participatory_process, :with_steps, organization:)
  end
  let(:step_id) { participatory_process.steps.first.id }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "add a component" do
    before do
      visit decidim_admin_participatory_processes.components_path(participatory_process)
    end

    context "when the process has active steps" do
      before do
        find("button[data-toggle=add-component-dropdown]").click

        within "#add-component-dropdown" do
          find(".dummy").click
        end

        expect(page).to have_no_content("Share tokens")

        within ".new_component" do
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

          within ".step-settings" do
            fill_in_i18n_editor(
              "component_step_settings_#{step_id}_dummy_step_translatable_text",
              "#step-#{step_id}-settings-dummy_step_translatable_text-tabs",
              en: "Dummy Text for Step"
            )
            all("input[type=checkbox]").first.click
          end

          click_button "Add component"
        end
      end

      it "is successfully created" do
        expect(page).to have_admin_callout("successfully")
        expect(page).to have_content("My component")
      end

      context "and then edit it" do
        before do
          within find("tr", text: "My component") do
            click_link "Configure"
          end
        end

        it "successfully displays initial values in the form" do
          within ".global-settings" do
            expect(all("input[type=checkbox]").last).to be_checked
          end

          within ".step-settings" do
            expect(all("input[type=checkbox]").first).to be_checked
          end
        end

        it "successfully edits it" do
          click_button "Update"

          expect(page).to have_admin_callout("successfully")
        end
      end
    end

    context "when the process doesn't have active steps" do
      let!(:participatory_process) do
        create(:participatory_process, organization:)
      end

      before do
        find("button[data-toggle=add-component-dropdown]").click

        within "#add-component-dropdown" do
          find(".dummy").click
        end

        within ".new_component" do
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

          within ".default-step-settings" do
            fill_in_i18n_editor(
              :component_default_step_settings_dummy_step_translatable_text,
              "#default-step-settings-dummy_step_translatable_text-tabs",
              en: "Dummy Text for Step"
            )
            all("input[type=checkbox]").first.click
          end

          click_button "Add component"
        end
      end

      it "is successfully created" do
        expect(page).to have_admin_callout("successfully")
        expect(page).to have_content("My component")
      end

      context "and then edit it" do
        before do
          within find("tr", text: "My component") do
            click_link "Configure"
          end
        end

        it "successfully displays initial values in the form" do
          within ".global-settings" do
            expect(all("input[type=checkbox]").last).to be_checked
          end

          within ".default-step-settings" do
            expect(all("input[type=checkbox]").first).to be_checked
          end
        end

        it "successfully edits it" do
          click_button "Update"

          expect(page).to have_admin_callout("successfully")
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
        step_settings: {
          step_id => { dummy_step_translatable_text: generate_localized_title }
        }
      )
    end

    before do
      visit decidim_admin_participatory_processes.components_path(participatory_process)
    end

    it "updates the component" do
      within ".component-#{component.id}" do
        click_link "Configure"
      end

      within ".edit_component" do
        fill_in_i18n(
          :component_name,
          "#component-name-tabs",
          en: "My updated component",
          ca: "La meva funcionalitat actualitzada",
          es: "Mi funcionalidad actualizada"
        )

        within ".global-settings" do
          all("input[type=checkbox]").last.click
        end

        within ".step-settings" do
          all("input[type=checkbox]").first.click
        end

        click_button "Update"
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_content("My updated component")

      within find("tr", text: "My updated component") do
        click_link "Configure"
      end

      within ".global-settings" do
        expect(all("input[type=checkbox]").last).to be_checked
      end

      within ".step-settings" do
        expect(all("input[type=checkbox]").first).to be_checked
      end
    end

    context "when the process doesn't have active steps" do
      before { participatory_process.steps.destroy_all }

      it "updates the default step settings" do
        within ".component-#{component.id}" do
          click_link "Configure"
        end

        within ".edit_component" do
          within ".default-step-settings" do
            all("input[type=checkbox]").first.click
          end

          click_button "Update"
        end

        expect(page).to have_admin_callout("successfully")

        within find("tr", text: "My component") do
          click_link "Configure"
        end

        within ".default-step-settings" do
          expect(all("input[type=checkbox]").first).to be_checked
        end
      end
    end
  end

  describe "remove a component" do
    let(:component_name) do
      {
        en: "My component",
        ca: "La meva funcionalitat",
        es: "Mi funcionalitat"
      }
    end

    let!(:component) do
      create(:component, name: component_name, participatory_space: participatory_process)
    end

    before do
      visit decidim_admin_participatory_processes.components_path(participatory_process)
    end

    it "removes the component" do
      within ".component-#{component.id}" do
        click_link "Delete"
      end

      expect(page).to have_no_content("My component")
    end
  end

  describe "publish and unpublish a component" do
    let!(:component) do
      create(:component, participatory_space: participatory_process, published_at:)
    end

    let(:published_at) { nil }

    before do
      visit decidim_admin_participatory_processes.components_path(participatory_process)
    end

    context "when the component is unpublished" do
      it "shows the share tokens section" do
        within ".component-#{component.id}" do
          click_link "Configure"
        end

        expect(page).to have_content("Share tokens")
      end

      it "publishes the component" do
        within ".component-#{component.id}" do
          click_link "Publish"
        end

        within ".component-#{component.id}" do
          expect(page).to have_css(".action-icon--unpublish")
        end
      end

      it "notifies its followers" do
        follower = create(:user, organization: participatory_process.organization)
        create(:follow, followable: participatory_process, user: follower)

        within ".component-#{component.id}" do
          click_link "Publish"
        end

        expect(enqueued_jobs.last[:args]).to include("decidim.events.components.component_published")
      end

      it_behaves_like "manage component share tokens"
    end

    context "when the component is published" do
      let(:published_at) { Time.current }

      it "does not show the share tokens section" do
        within ".component-#{component.id}" do
          click_link "Configure"
        end

        expect(page).to have_no_content("Share tokens")
      end

      it "unpublishes the component" do
        within ".component-#{component.id}" do
          click_link "Unpublish"
        end

        within ".component-#{component.id}" do
          expect(page).to have_css(".action-icon--publish")
        end
      end
    end
  end

  def participatory_space
    participatory_process
  end

  def participatory_space_components_path(participatory_space)
    decidim_admin_participatory_processes.components_path(participatory_space)
  end
end
