# frozen_string_literal: true

shared_examples "access mode transparent participatory spaces" do
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
        within "h2" do
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

      it "lists all the spaces" do
        within css_class_selector do
          within "h2" do
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

shared_examples "access mode transparent participatory spaces comments" do
  let!(:participatory_space) { transparent_participatory_space }
  let!(:component) { create(:dummy_component, participatory_space:) }
  let!(:commentable) { create(:dummy_resource, component:) }
  let!(:comment) { create(:comment, commentable:, author: user) }

  let!(:user) { create(:user, :confirmed, organization:) }
  let!(:other_user) { create(:user, :confirmed, organization:) }
  let!(:member_user) { create(:user, :confirmed, organization:) }
  let!(:member) { create(:member, user: member_user, participatory_space:) }

  let(:resource_path) { resource_locator(commentable).path }

  before do
    switch_to_host(organization.host)
  end

  context "when the user is not logged in" do
    before do
      visit resource_path
    end

    it "can see the comments" do
      expect(page).to have_css("#comments")
      expect(page).to have_content(comment.body["en"])
    end

    it "cannot see the comment form" do
      expect(page).to have_no_css("form#new_comment_for_DummyResource_#{commentable.id}")
    end

    it "cannot see the vote buttons" do
      expect(page).to have_no_css(".js-comment__votes--up")
      expect(page).to have_no_css(".js-comment__votes--down")
    end
  end

  context "when the user is logged in and is a member" do
    before do
      login_as member_user, scope: :user
      visit resource_path
    end

    it "can see the comments" do
      expect(page).to have_css("#comments")
      expect(page).to have_content(comment.body["en"])
    end

    it "can see the comment form" do
      expect(page).to have_css("form#new_comment_for_DummyResource_#{commentable.id}")
    end

    it "can add a new comment" do
      within "form#new_comment_for_DummyResource_#{commentable.id}" do
        fill_in "add-comment-DummyResource-#{commentable.id}", with: "This is a test comment from a member"
        click_on "Publish comment"
      end

      expect(page).to have_content("This is a test comment from a member")
    end

    it "can see the vote buttons" do
      if commentable.comments_have_votes?
        expect(page).to have_css(".comment__votes button", minimum: 2)
      else
        expect(page).to have_no_css(".comment__votes button")
      end
    end

    it "can vote on a comment" do
      skip "Commentable comments has no votes" unless commentable.comments_have_votes?

      within "#comment_#{comment.id}" do
        click_on(".comment__votes button", match: :first)
      end

      expect(page).to have_css(".comment__votes button.is-vote-selected")
    end
  end

  context "when the user is logged in and is not a member" do
    before do
      login_as other_user, scope: :user
      visit resource_path
    end

    it "can see the comments" do
      expect(page).to have_css("#comments")
      expect(page).to have_content(comment.body["en"])
    end

    it "cannot see the comment form" do
      expect(page).to have_no_css("form#new_comment_for_DummyResource_#{commentable.id}")
      expect(page).to have_content("You are not able to comment at this moment")
    end

    it "cannot see the vote buttons" do
      expect(page).to have_no_css(".js-comment__votes--up")
      expect(page).to have_no_css(".js-comment__votes--down")
    end
  end

  context "when the user is logged in and is a member" do
    before do
      login_as member_user, scope: :user
      visit resource_path
    end

    it "can see the comments" do
      expect(page).to have_css("#comments")
      expect(page).to have_content(comment.body["en"])
    end

    it "can see the comment form" do
      expect(page).to have_css("form#new_comment_for_DummyResource_#{commentable.id}")
    end

    it "can add a new comment" do
      within "form#new_comment_for_DummyResource_#{commentable.id}" do
        fill_in "add-comment-DummyResource-#{commentable.id}", with: "This is a test comment from a member"
        click_on "Publish comment"
      end

      expect(page).to have_content("This is a test comment from a member")
    end

    it "can see the vote buttons" do
      if commentable.comments_have_votes?
        expect(page).to have_css(".comment__votes button", minimum: 2)
      else
        expect(page).to have_no_css(".comment__votes button")
      end
    end

    it "can vote on a comment" do
      skip "Commentable comments has no votes" unless commentable.comments_have_votes?

      within "#comment_#{comment.id}" do
        click_on(".comment__votes button", match: :first)
      end

      expect(page).to have_css(".comment__votes button.is-vote-selected")
    end
  end

  context "when the user is logged in and is not a member" do
    before do
      login_as other_user, scope: :user
      visit resource_path
    end

    it "can see the comments" do
      expect(page).to have_css("#comments")
      expect(page).to have_content(comment.body["en"])
    end

    it "cannot see the comment form" do
      expect(page).to have_no_css("form#new_comment_for_DummyResource_#{commentable.id}")
      expect(page).to have_content("You are not able to comment at this moment")
    end

    it "cannot see the vote buttons" do
      expect(page).to have_no_css(".js-comment__votes--up")
      expect(page).to have_no_css(".js-comment__votes--down")
    end
  end
end
