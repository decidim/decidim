# frozen_string_literal: true

shared_examples "access mode transparent participatory spaces" do
  let!(:organization) { create(:organization) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let!(:other_user) { create(:user, :confirmed, organization:) }
  let!(:other_user2) { create(:user, :confirmed, organization:) }

  context "and no user is logged in" do
    before do
      switch_to_host(organization.host)
      visit participatory_space_index_path
    end

    it "lists all the spaces" do
      within css_class_selector do
        within "#{css_class_selector} h2" do
          expect(page).to have_content("2")
        end

        expect(page).to have_content(translated(participatory_space.title, locale: :en))
        expect(page).to have_css(".card__grid", count: 2)

        expect(page).to have_content(translated(transparent_participatory_space.title, locale: :en))
      end
    end

    it "links to the individual space page" do
      first(".card__grid-text", text: translated(transparent_participatory_space.title, locale: :en)).click

      expect(page).to have_current_path transparent_participatory_space_path
      expect(page).to have_content "This is a transparent space"
    end
  end

  context "when user is logged in" do
    context "when is not a space member" do
      before do
        switch_to_host(organization.host)
        login_as user, scope: :user
        visit participatory_space_index_path
      end

      it "lists all the assemblies" do
        within css_class_selector do
          within "#{css_class_selector} h2" do
            expect(page).to have_content("2")
          end

          expect(page).to have_content(translated(participatory_space.title, locale: :en))
          expect(page).to have_css(".card__grid", count: 2)

          expect(page).to have_content(translated(transparent_participatory_space.title, locale: :en))
        end
      end
    end

    context "when the user is admin" do
      before do
        switch_to_host(organization.host)
        login_as admin, scope: :user
        visit participatory_space_index_path
      end

      it "does not show the privacy warning in attachments admin" do
        visit transparent_participatory_space_attachment_path
        within "#attachments" do
          expect(page).to have_no_content("Any participant could share this document to others")
        end
      end
    end
  end
end
