# frozen_string_literal: true

shared_examples "manage posts" do
  it_behaves_like "having a rich text editor for field", ".tabs-content[data-tabs-content='post-body-tabs']", "full" do
    before do
      within find("tr", text: translated(post1.title)) do
        click_link "Edit"
      end
    end
  end

  it "updates a post" do
    within find("tr", text: translated(post1.title)) do
      click_link "Edit"
    end

    within ".edit_post" do
      expect(page).to have_select("post_decidim_author_id", selected: author.name)

      fill_in_i18n(
        :post_title,
        "#post-title-tabs",
        en: "My new title",
        es: "Mi nuevo título",
        ca: "El meu nou títol"
      )
      fill_in_i18n_editor(
        :post_body,
        "#post-body-tabs",
        en: "A longer description",
        es: "Descripción más larga",
        ca: "Descripció més llarga"
      )

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "table" do
      expect(page).to have_content("My new title")
      expect(page).to have_content("Post title 2")
      expect(page).to have_content(author.name)
    end
  end

  it "creates a new post" do
    click_link "New post"

    fill_in_i18n(
      :post_title,
      "#post-title-tabs",
      en: "My post",
      es: "Mi post",
      ca: "El meu post"
    )

    fill_in_i18n_editor(
      :post_body,
      "#post-body-tabs",
      en: "A description",
      es: "Descripción",
      ca: "Descripció"
    )

    within ".new_post" do
      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "table" do
      expect(page).to have_content("My post")
      expect(page).to have_content("Post title 1")
      expect(page).to have_content("Post title 2")
    end
  end

  describe "deleting a post" do
    before do
      visit current_path
    end

    it "deletes a post" do
      within find("tr", text: translated(post1.title)) do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).not_to have_content(translated(post1.title))
        expect(page).to have_content(translated(post2.title))
      end
    end
  end

  context "when user is in user group" do
    let(:user_group) { create(:user_group, :confirmed, :verified, organization:) }
    let!(:membership) { create(:user_group_membership, user:, user_group:) }

    it "can set user group as posts author" do
      click_link "New post"

      select user_group.name, from: "post_decidim_author_id"

      fill_in_i18n(
        :post_title,
        "#post-title-tabs",
        en: "My post",
        es: "Mi post",
        ca: "El meu post"
      )

      fill_in_i18n_editor(
        :post_body,
        "#post-body-tabs",
        en: "A description",
        es: "Descripción",
        ca: "Descripció"
      )

      within ".new_post" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content(user_group.name)
        expect(page).to have_content("My post")
        expect(page).to have_content("Post title 1")
        expect(page).to have_content("Post title 2")
      end
    end

    it "can update the user group as the post author" do
      within find("tr", text: translated(post1.title)) do
        click_link "Edit"
      end

      within ".edit_post" do
        select user_group.name, from: "post_decidim_author_id"
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within find("tr", text: translated(post1.title)) do
        expect(page).to have_content(user_group.name)
      end
    end
  end

  context "when user is the organization" do
    let(:author) { organization }

    it "can set organization as posts author" do
      click_link "New post"

      select organization.name, from: "post_decidim_author_id"

      fill_in_i18n(
        :post_title,
        "#post-title-tabs",
        en: "My post",
        es: "Mi post",
        ca: "El meu post"
      )

      fill_in_i18n_editor(
        :post_body,
        "#post-body-tabs",
        en: "A description",
        es: "Descripción",
        ca: "Descripció"
      )

      within ".new_post" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content(author.name)
        expect(page).to have_content("My post")
        expect(page).to have_content("Post title 1")
        expect(page).to have_content("Post title 2")
      end
    end

    it "can update the blog as the organization" do
      within find("tr", text: translated(post1.title)) do
        click_link "Edit"
      end

      within ".edit_post" do
        select organization.name, from: "post_decidim_author_id"
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within find("tr", text: translated(post1.title)) do
        expect(page).to have_content(author.name)
      end
    end
  end

  context "when user is current_user" do
    let(:author) { user }

    it "can set current_user as posts author" do
      click_link "New post"

      select user.name, from: "post_decidim_author_id"

      fill_in_i18n(
        :post_title,
        "#post-title-tabs",
        en: "My post",
        es: "Mi post",
        ca: "El meu post"
      )

      fill_in_i18n_editor(
        :post_body,
        "#post-body-tabs",
        en: "A description",
        es: "Descripción",
        ca: "Descripció"
      )

      within ".new_post" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content(author.name)
        expect(page).to have_content("My post")
        expect(page).to have_content("Post title 1")
        expect(page).to have_content("Post title 2")
      end
    end

    it "can update the blog as the user" do
      within find("tr", text: translated(post1.title)) do
        click_link "Edit"
      end

      within ".edit_post" do
        select user.name, from: "post_decidim_author_id"
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within find("tr", text: translated(post1.title)) do
        expect(page).to have_content(author.name)
      end
    end

    it "changes the publish time" do
      within find("tr", text: translated(post1.title)) do
        click_link "Edit"
      end
      within ".edit_post" do
        fill_in "Publish time", with: Time.current.change(year: 2022, month: 1, day: 1, hour: 0, min: 0)
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_content("01/01/2022 00:00")
    end
  end
end
