# frozen_string_literal: true

shared_examples "manage conference speakers examples" do
  let!(:conference_speaker) { create(:conference_speaker, conference: conference) }
  let(:attributes) { attributes_for(:conference_speaker, conference: conference) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_conferences.edit_conference_path(conference)
    click_link "Speakers"
  end

  it "shows conference speakers list" do
    within "#conference_speakers table" do
      expect(page).to have_content(conference_speaker.full_name)
    end
  end

  context "without existing user" do
    it "creates a new conference speaker", versioning: true do
      find(".card-title a.new").click

      within ".new_conference_speaker" do
        fill_in(:conference_speaker_full_name, with: attributes[:full_name])
        fill_in_i18n(:conference_speaker_position, "#conference_speaker-position-tabs", **attributes[:position].except("machine_translations"))
        fill_in_i18n(:conference_speaker_affiliation, "#conference_speaker-affiliation-tabs", **attributes[:affiliation].except("machine_translations"))
        fill_in_i18n_editor(:conference_speaker_short_bio, "#conference_speaker-short_bio-tabs", **attributes[:short_bio].except("machine_translations"))

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_current_path decidim_admin_conferences.conference_speakers_path(conference)

      within "#conference_speakers table" do
        expect(page).to have_content(attributes[:full_name])
      end
      visit decidim_admin.root_path
      expect(page).to have_content("created the #{attributes[:full_name]} speaker in the")
    end
  end

  context "with existing user" do
    let!(:speaker_user) { create :user, organization: conference.organization }

    it "creates a new conference speaker" do
      find(".card-title a.new").click

      within ".new_conference_speaker" do
        select "Existing participant", from: :conference_speaker_existing_user
        autocomplete_select "#{speaker_user.name} (@#{speaker_user.nickname})", from: :user_id

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_current_path decidim_admin_conferences.conference_speakers_path(conference)

      within "#conference_speakers table" do
        expect(page).to have_content("#{speaker_user.name} (@#{speaker_user.nickname})")
      end
    end
  end

  describe "when managing other conference speakers" do
    before do
      visit current_path
    end

    it "updates an conference speaker", versioning: true do
      within find("#conference_speakers tr", text: conference_speaker.full_name) do
        click_link "Edit"
      end

      within ".edit_conference_speaker" do
        fill_in(:conference_speaker_full_name, with: attributes[:full_name])
        fill_in_i18n(:conference_speaker_position, "#conference_speaker-position-tabs", **attributes[:position].except("machine_translations"))
        fill_in_i18n(:conference_speaker_affiliation, "#conference_speaker-affiliation-tabs", **attributes[:affiliation].except("machine_translations"))
        fill_in_i18n_editor(:conference_speaker_short_bio, "#conference_speaker-short_bio-tabs", **attributes[:short_bio].except("machine_translations"))

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_current_path decidim_admin_conferences.conference_speakers_path(conference)

      within "#conference_speakers table" do
        expect(page).to have_content(attributes[:full_name])
      end
      visit decidim_admin.root_path
      expect(page).to have_content("updated the #{conference_speaker.full_name} speaker in the")
    end

    it "deletes the conference speaker" do
      within find("#conference_speakers tr", text: conference_speaker.full_name) do
        accept_confirm { find("a.action-icon--remove").click }
      end

      expect(page).to have_admin_callout("successfully")

      within "#conference_speakers table" do
        expect(page).to have_no_content(conference_speaker.full_name)
      end
    end
  end
end
