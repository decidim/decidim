# frozen_string_literal: true

# we really need the audit_check variable, as it seems that a process admin should not be able to see the admin logs
# Therefore, as long we do have the logs checks in this shared example, we need to have the config flag.
shared_examples "manage posts" do |audit_check: true|
  it_behaves_like "having a rich text editor for field", ".tabs-content[data-tabs-content='post-body-tabs']", "full" do
    before do
      within find("tr", text: translated(post1.title)) do
        click_link "Edit"
      end
    end
  end
  let(:attributes) { attributes_for(:post) }

  it "updates a post", versioning: true do
    within find("tr", text: translated(post1.title)) do
      click_link "Edit"
    end

    within ".edit_post" do
      expect(page).to have_select("post_decidim_author_id", selected: author.name)

      fill_in_i18n(:post_title, "#post-title-tabs", **attributes[:title].except("machine_translations"))
      fill_in_i18n_editor(:post_body, "#post-body-tabs", **attributes[:body].except("machine_translations"))

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "table" do
      expect(page).to have_content(translated(attributes[:title]))
      expect(page).to have_content("Post title 2")
      expect(page).to have_content(author.name)
    end

    if audit_check == true
      visit decidim_admin.root_path
      expect(page).to have_content("updated the #{translated(attributes[:title])} blog post")
    end
  end

  it "creates a new post", versioning: true do
    click_link "New post"

    fill_in_i18n(:post_title, "#post-title-tabs", **attributes[:title].except("machine_translations"))
    fill_in_i18n_editor(:post_body, "#post-body-tabs", **attributes[:body].except("machine_translations"))

    within ".new_post" do
      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "table" do
      expect(page).to have_content(translated(attributes[:title]))
      expect(page).to have_content("Post title 1")
      expect(page).to have_content("Post title 2")
    end

    if audit_check == true
      visit decidim_admin.root_path
      expect(page).to have_content("created the #{translated(attributes[:title])} blog post")
    end

    visit decidim.last_activities_path
    expect(page).to have_content("New post: #{translated(attributes[:title])}")

    within "#filters" do
      find("a", class: "filter", text: "Post", match: :first).click
    end
    expect(page).to have_content("New post: #{translated(attributes[:title])}")
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
