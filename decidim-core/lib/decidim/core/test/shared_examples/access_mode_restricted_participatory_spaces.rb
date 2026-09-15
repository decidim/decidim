# frozen_string_literal: true

shared_examples "access mode restricted participatory spaces" do
  let!(:organization) { create(:organization) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let!(:user) { create(:user, :confirmed, organization:) }

  context "and no user is logged in" do
    before do
      switch_to_host(organization.host)
      visit participatory_space_index_path
    end

    it "does not list the restricted participatory space" do
      within css_class_selector do
        within "h2" do
          expect(page).to have_text("1")
        end

        expect(page).to have_text(translated(participatory_space.title, locale: :en))
        expect(page).to have_css(".card__grid", count: 1)

        expect(page).to have_no_text(translated(restricted_participatory_space.title, locale: :en))
      end
    end
  end

  context "when user is logged in and is not a participatory space member" do
    context "when the user is not admin" do
      before do
        switch_to_host(organization.host)
        login_as user, scope: :user
        visit participatory_space_index_path
      end

      it "does not list the restricted participatory space" do
        within css_class_selector do
          within "h2" do
            expect(page).to have_text("1")
          end

          expect(page).to have_text(translated(participatory_space.title, locale: :en))
          expect(page).to have_css(".card__grid", count: 1)

          expect(page).to have_no_text(translated(restricted_participatory_space.title, locale: :en))
        end
      end
    end

    context "when the user is admin" do
      before do
        switch_to_host(organization.host)
        login_as admin, scope: :user
        visit participatory_space_index_path
      end

      it "lists restricted participatory spaces" do
        within css_class_selector do
          within "h2" do
            expect(page).to have_text("2")
          end

          expect(page).to have_text(translated(participatory_space.title, locale: :en))
          expect(page).to have_text(translated(restricted_participatory_space.title, locale: :en))
          expect(page).to have_css(".card__grid", count: 2)
        end
      end

      it "links to the individual participatory space page" do
        first(".card__grid-text", text: translated(restricted_participatory_space.title, locale: :en)).click

        expect(page).to have_current_path restricted_participatory_space_path
        expect(page).to have_text "This is a restricted space"
      end

      it "shows the privacy warning in attachments admin" do
        visit restricted_participatory_space_attachment_path
        within "#attachments" do
          expect(page).to have_text(I18n.t("decidim.admin.attachments_privacy_warning.message"))
        end
      end
    end
  end

  context "when user is logged in and is an participatory space member" do
    before do
      switch_to_host(organization.host)
      login_as other_user, scope: :user
      visit participatory_space_index_path
    end

    it "lists restricted participatory spaces" do
      within css_class_selector do
        within "h2" do
          expect(page).to have_text("2")
        end

        expect(page).to have_text(translated(participatory_space.title, locale: :en))
        expect(page).to have_text(translated(restricted_participatory_space.title, locale: :en))
        expect(page).to have_css(".card__grid", count: 2)
      end
    end

    it "links to the individual participatory space page" do
      first(".card__grid-text", text: translated(restricted_participatory_space.title, locale: :en)).click

      expect(page).to have_current_path restricted_participatory_space_path
      expect(page).to have_text "This is a restricted space"
    end
  end
end

shared_examples "access mode restricted participatory spaces comments" do
  let!(:participatory_space) { restricted_participatory_space }
  let!(:member) { create(:member, user: member_user, participatory_space:) }
  let!(:component) { create(:dummy_component, participatory_space:) }
  let!(:commentable) { create(:dummy_resource, component:) }
  let!(:comment) { create(:comment, commentable:, author: user) }

  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let!(:other_user) { create(:user, :confirmed, organization:) }
  let!(:member_user) { create(:user, :confirmed, organization:) }

  let(:resource_path) { resource_locator(commentable).path }

  before do
    switch_to_host(organization.host)
  end

  context "when the user is not logged in" do
    it "cannot access the page" do
      visit resource_path
      expect(page).to have_text("You are not authorized to perform this action")
    end
  end

  context "when the user is logged in and is a member" do
    before do
      login_as member_user, scope: :user
      visit resource_path
    end

    it "can see the comments" do
      expect(page).to have_css("#comments")
      expect(page).to have_text(comment.body["en"])
    end

    it "can see the comment form" do
      expect(page).to have_css("form#new_comment_for_DummyResource_#{commentable.id}")
    end

    it "can see the vote buttons" do
      if commentable.comments_have_votes?
        expect(page).to have_css(".comment__votes button", minimum: 2)
      else
        expect(page).to have_no_css(".comment__votes button")
      end
    end
  end

  context "when the user is logged in and is not a member" do
    before do
      login_as other_user, scope: :user
      visit resource_path
    end

    it "cannot access the page" do
      expect(page).to have_text("You are not authorized to perform this action")
    end
  end
end
