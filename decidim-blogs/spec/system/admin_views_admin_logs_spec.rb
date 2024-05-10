# frozen_string_literal: true

require "spec_helper"

describe "Admin views admin logs" do
  let(:manifest_name) { "blogs" }
  let(:two_days_ago) { 2.days.ago.strftime("%d/%m/%Y %H:%M") }
  let!(:post1) { create(:post, component: current_component, author:, title: { en: "Post title 1" }, created_at: two_days_ago, published_at: two_days_ago) }
  let(:author) { organization }

  let(:attributes) { attributes_for(:post) }

  include_context "when managing a component as an admin"

  it "updates a post", versioning: true do
    within "tr", text: translated(post1.title) do
      click_on "Edit"
    end

    within ".edit_post" do
      expect(page).to have_select("post_decidim_author_id", selected: author.name)

      fill_in_i18n(:post_title, "#post-title-tabs", **attributes[:title].except("machine_translations"))
      fill_in_i18n_editor(:post_body, "#post-body-tabs", **attributes[:body].except("machine_translations"))

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    visit decidim_admin.root_path
    expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
  end

  it "creates a new post", versioning: true do
    click_on "New post"

    fill_in_i18n(:post_title, "#post-title-tabs", **attributes[:title].except("machine_translations"))
    fill_in_i18n_editor(:post_body, "#post-body-tabs", **attributes[:body].except("machine_translations"))

    within ".new_post" do
      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    visit decidim_admin.root_path
    expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
  end
end
