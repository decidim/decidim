# frozen_string_literal: true

require "spec_helper"

describe "Edit initiative" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }
  let(:initiative_title) { translated(initiative.title) }
  let(:new_title) { "This is my initiative new title" }

  let!(:initiative_type) { create(:initiatives_type, :attachments_enabled, :online_signature_enabled, organization:) }
  let!(:scoped_type) { create(:initiatives_type_scope, type: initiative_type) }

  let!(:other_initiative_type) { create(:initiatives_type, :attachments_enabled, organization:) }
  let!(:other_scoped_type) { create(:initiatives_type_scope, type: initiative_type) }

  let(:initiative_path) { decidim_initiatives.initiative_path(initiative, locale: I18n.locale) }
  let(:edit_initiative_path) { decidim_initiatives.edit_initiative_path(initiative, locale: I18n.locale) }

  shared_examples "manage update" do
    it "can be updated" do
      visit initiative_path

      within ".initiative__aside" do
        click_on("Edit")
      end

      expect(page).to have_content "Edit Initiative"

      within "form.edit_initiative" do
        fill_in :initiative_title, with: new_title
        click_on "Update"
      end

      expect(page).to have_content(new_title)
    end
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "when user is initiative author" do
    let(:initiative) { create(:initiative, :created, author: user, scoped_type:, organization:) }

    it_behaves_like "manage update"

    it "does not show the header's edit link" do
      visit initiative_path

      within ".main-bar" do
        expect(page).to have_no_link("Edit")
      end
    end

    it "does not have status field" do
      expect(page).to have_no_xpath("//select[@id='initiative_state']")
    end

    it "allows adding attachments" do
      visit initiative_path

      click_on("Edit")

      expect(page).to have_content "Edit Initiative"

      expect(initiative.reload.attachments.count).to eq(0)

      dynamically_attach_file(:initiative_documents, Decidim::Dev.asset("Exampledocument.pdf"))
      dynamically_attach_file(:initiative_photos, Decidim::Dev.asset("avatar.jpg"))

      within "form.edit_initiative" do
        click_on "Update"
      end

      expect(initiative.reload.documents.count).to eq(1)
      expect(initiative.photos.count).to eq(1)
      expect(initiative.attachments.count).to eq(2)
    end

    context "when using the wizard steps" do
      before do
        visit decidim_initiatives.load_initiative_draft_create_initiative_index_path(initiative_id: initiative.id, locale: I18n.locale)
      end

      it "can be updated" do
        click_on "Back"

        fill_in :initiative_title, with: "New title"
        click_on "Continue"

        expect(page).to have_content("The initiative has been successfully updated.")
        expect(translated(initiative.reload.title)).to eq("New title")
      end

      it "can be discarded" do
        click_on "Back"
        click_on "Discard"

        expect(page).to have_content("Are you sure you want to discard this initiative?")
        click_on "OK"

        expect(page).to have_content("The initiative has been successfully discarded.")
        expect(translated(initiative.reload.state)).to eq("discarded")
      end
    end

    context "when initiative is published" do
      let(:initiative) { create(:initiative, author: user, scoped_type:, organization:) }

      it "cannot be updated" do
        visit initiative_path

        expect(page).to have_no_content "Edit initiative"

        visit edit_initiative_path

        expect(page).to have_content("not authorized")
      end
    end
  end

  describe "when author is a committee member" do
    let(:initiative) { create(:initiative, :created, scoped_type:, organization:) }

    before do
      create(:initiatives_committee_member, user:, initiative:)
    end

    it_behaves_like "manage update"
  end

  describe "when user is admin" do
    let(:user) { create(:user, :confirmed, :admin, organization:) }
    let(:initiative) { create(:initiative, :created, scoped_type:, organization:) }

    it_behaves_like "manage update"
  end

  describe "when author is not a committee member" do
    let(:initiative) { create(:initiative, :created, scoped_type:, organization:) }

    it "renders an error" do
      visit initiative_path

      expect(page).to have_no_content("Edit initiative")

      visit edit_initiative_path

      expect(page).to have_content("not authorized")
    end
  end

  context "when rich text editor is enabled for participants" do
    let(:initiative) { create(:initiative, :created, author: user, scoped_type:, organization:) }
    let(:organization) { create(:organization, rich_text_editor_in_public_views: true) }

    before do
      visit initiative_path

      click_on("Edit")

      expect(page).to have_content "Edit Initiative"
    end

    it_behaves_like "having a rich text editor", "edit_initiative", "content"
  end
end
