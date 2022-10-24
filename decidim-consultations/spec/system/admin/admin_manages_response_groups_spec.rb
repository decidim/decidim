# frozen_string_literal: true

require "spec_helper"

describe "Admin manages response groups", type: :system do
  include_context "when administrating a consultation"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_consultations.responses_path(question)
  end

  context "when question is not multiple" do
    it "do not have response groups link" do
      expect(page).not_to have_link("Manage response groups")
    end
  end

  context "when question is multiple" do
    let!(:question) { create :question, :multiple, consultation: }

    it "have groups link" do
      expect(page).to have_link("Manage response groups", href: decidim_admin_consultations.response_groups_path(question))
    end
  end

  context "when in groups admin page" do
    let!(:question) { create :question, :multiple, consultation: }
    let!(:response_group) { create :response_group, question: }
    # let(:extra_context) { { current_response_group: response_group } }

    before do
      visit decidim_admin_consultations.response_groups_path(question)
    end

    describe "creating a response group" do
      before do
        click_link("New group")
      end

      it "creates a new response group" do
        within ".new_response_group" do
          fill_in_i18n(
            :response_group_title,
            "#response_group-title-tabs",
            en: "My response group",
            es: "Mi grupo de respuestas",
            ca: "El meu grup de respostes"
          )

          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("successfully")

        within ".container" do
          expect(page).to have_current_path decidim_admin_consultations.response_groups_path(question)
          expect(page).to have_content("My response group")
        end
      end
    end

    describe "trying to create a response with invalid data" do
      before do
        click_link("New group")
      end

      it "fails to create a new response" do
        within ".new_response_group" do
          fill_in_i18n(
            :response_group_title,
            "#response_group-title-tabs",
            en: "",
            es: "",
            ca: ""
          )

          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("problem")
      end
    end

    describe "updating a group" do
      before do
        click_link translated(response_group.title)
      end

      it "updates a group" do
        fill_in_i18n(
          :response_group_title,
          "#response_group-title-tabs",
          en: "My new title",
          es: "Mi nuevo título",
          ca: "El meu nou títol"
        )

        within ".edit_response_group" do
          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("successfully")

        within ".container" do
          expect(page).to have_current_path decidim_admin_consultations.response_groups_path(question)
        end
      end
    end

    describe "updating a response group with invalid values" do
      before do
        click_link translated(response_group.title)
      end

      it "do not updates the response group" do
        fill_in_i18n(
          :response_group_title,
          "#response_group-title-tabs",
          en: "",
          es: "",
          ca: ""
        )

        within ".edit_response_group" do
          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("problem")
      end
    end
  end

  describe "deleting a response group" do
    let!(:question) { create :question, :multiple, consultation: }
    let!(:response_group) { create :response_group, question: }

    before do
      visit decidim_admin_consultations.edit_response_group_path(question, response_group)
    end

    context "when no responses attached" do
      it "deletes group" do
        accept_confirm { click_link "Delete" }

        expect(page).to have_admin_callout("successfully")

        within "table" do
          expect(page).not_to have_content(translated(response_group.title))
        end
      end
    end

    context "when has responses" do
      let!(:response) { create :response, response_group: }

      it "deletes group" do
        accept_confirm { click_link "Delete" }

        expect(page).to have_admin_callout("problem")

        within "table" do
          expect(page).to have_content(translated(response_group.title))
        end
      end
    end
  end
end
