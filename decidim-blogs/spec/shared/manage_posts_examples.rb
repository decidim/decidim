# frozen_string_literal: true

shared_examples "manage posts" do
  it "updates a post" do
    within find("tr", text: translated(post1.title)) do
      click_link "Edit"
    end

    within ".edit_post" do
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
    end
  end

  it "creates a new post", :slow do
    find(".card-title a.button").click

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
        expect(page).to have_no_content(translated(post1.title))
        expect(page).to have_content(translated(post2.title))
      end
    end
  end
end
