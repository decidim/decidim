# frozen_string_literal: true

require "spec_helper"

describe "Admin manages initiatives" do
  STATES = Decidim::Initiative.states.keys.map(&:to_sym)

  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, :admin, organization:) }
  let(:model_name) { Decidim::Initiative.model_name }
  let(:resource_controller) { Decidim::Initiatives::Admin::InitiativesController }
  let(:type1) { create(:initiatives_type, organization:) }
  let(:type2) { create(:initiatives_type, organization:) }
  let(:scoped_type1) { create(:initiatives_type_scope, type: type1) }
  let(:scoped_type2) { create(:initiatives_type_scope, type: type2) }
  let(:area1) { create(:area, organization:) }
  let(:area2) { create(:area, organization:) }

  def create_initiative_with_trait(trait)
    create(:initiative, trait, organization:)
  end

  def initiative_with_state(state)
    Decidim::Initiative.find_by(state:)
  end

  def initiative_without_state(state)
    Decidim::Initiative.where.not(state:).sample
  end

  def initiative_with_type(type)
    Decidim::Initiative.join(:scoped_type).find_by(decidim_initiatives_types_id: type)
  end

  def initiative_without_type(type)
    Decidim::Initiative.join(:scoped_type).where.not(decidim_initiatives_types_id: type).sample
  end

  def initiative_with_area(area)
    Decidim::Initiative.find_by(decidim_area_id: area)
  end

  def initiative_without_area(area)
    Decidim::Initiative.where.not(decidim_area_id: area).sample
  end

  include_context "with filterable context"

  STATES.each do |state|
    let!(:"#{state}_initiative") { create_initiative_with_trait(state) }
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_initiatives.initiatives_path(locale: I18n.locale)
  end

  describe "listing initiatives" do
    STATES.each do |state|
      context "when filtering collection by state: #{I18n.t(state, scope: "decidim.admin.filters.initiatives.state_eq.values")}" do
        it_behaves_like "a filtered collection", options: "State", filter: I18n.t(state, scope: "decidim.admin.filters.initiatives.state_eq.values") do
          let(:in_filter) { translated(initiative_with_state(state).title) }
          let(:not_in_filter) { translated(initiative_without_state(state).title) }
        end
      end
    end

    Decidim::InitiativesTypeScope.all.each do |scoped_type|
      let(:type) { scoped_type.type }

      context "when filtering collection by type: #{scoped_type.type.title[I18n.locale.to_s]}" do
        before do
          create(:initiative, organization:, scoped_type: scoped_type1)
          create(:initiative, organization:, scoped_type: scoped_type2)
        end

        it_behaves_like "a filtered collection", options: "Type", filter: scoped_type.type.title[I18n.locale.to_s] do
          let(:in_filter) { translated(initiative_with_type(type).title) }
          let(:not_in_filter) { translated(initiative_without_type(type).title) }
        end
      end
    end

    it "can be searched by title" do
      search_by_text(translated(open_initiative.title))

      expect(page).to have_text(translated(open_initiative.title))
    end

    Decidim::Area.all.each do |area|
      context "when filtering collection by area: #{area.name[I18n.locale.to_s]}" do
        before do
          create(:initiative, organization:, area: area1)
          create(:initiative, organization:, area: area2)
        end

        it_behaves_like "a filtered collection", options: "Area", filter: area.name[I18n.locale.to_s] do
          let(:in_filter) { translated(initiative_with_area(area).title) }
          let(:not_in_filter) { translated(initiative_without_area(area).title) }
        end
      end
    end

    it "can be searched by description" do
      search_by_text(translated(open_initiative.description))

      expect(page).to have_text(translated(open_initiative.title))
    end

    it "can be searched by author name" do
      search_by_text(open_initiative.author.name)

      expect(page).to have_text(translated(open_initiative.title))
    end

    it "can be searched by author nickname" do
      search_by_text(open_initiative.author.nickname)

      expect(page).to have_text(translated(open_initiative.title))
    end

    it_behaves_like "paginating a collection"
  end

  context "when the initiative has an attachment" do
    let!(:initiative_with_attachment) { create(:initiative, organization:) }
    let!(:document) { create(:attachment, :with_image, attached_to: initiative_with_attachment) }

    it "can remove an attachment" do
      visit decidim_admin_initiatives.edit_initiative_path(initiative_with_attachment)
      click_on("Edit")

      find("tbody tr:first-child button[data-controller='dropdown']").click
      click_on "Delete"

      click_on "OK"

      expect(page).to have_text("Attachment destroyed successfully.")

      visit decidim_admin_initiatives.edit_initiative_path(initiative_with_attachment)

      expect(page).to have_no_text(document.file.blob.filename.to_s)
    end

    it "can attach a file" do
      visit decidim_admin_initiatives.edit_initiative_path(initiative_with_attachment)

      within("#accordion-homepage_attachments") do
        click_on("New")
      end

      fill_in_i18n(
        :attachment_title,
        "#attachment-title-tabs",
        en: "Super city!"
      )
      fill_in_i18n(
        :attachment_description,
        "#attachment-description-tabs",
        en: "Attachment description"
      )

      click_on("Add file")

      within(".upload-modal") do
        find("input[type='file']", visible: :all).attach_file(Decidim::Dev.asset("city3.jpeg"))
        click_on("Save")
      end

      click_on("Create attachment")

      expect(page).to have_text("Super city!")
    end

    it "can edit an initiative with an attachment" do
      visit decidim_admin_initiatives.edit_initiative_path(initiative_with_attachment)

      expect(page.html).to include(document.file.blob.filename.to_s)

      fill_in_i18n(
        :initiative_title,
        "#initiative-title-tabs",
        en: "Updated initiative title with attachments"
      )

      within("[data-content]") do
        find("*[type=submit]").click
      end

      expect(page).to have_callout "The initiative has been successfully updated."

      visit decidim_admin_initiatives.edit_initiative_path(initiative_with_attachment)

      expect(page.html).to include(document.file.blob.filename.to_s)
      expect(page).to have_field("initiative_title_en", with: "Updated initiative title with attachments")
    end
  end
end
