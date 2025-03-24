# frozen_string_literal: true

require "spec_helper"

describe "Admin manages initiative publication" do
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:organization) { create(:organization) }

  # To be published, the initiative needs to be in the :validating state
  let!(:initiative) { create(:initiative, :validating, organization:) }

  let(:admin_page_path) { decidim_admin_initiatives.edit_initiative_path(participatory_space) }
  let(:public_collection_path) { decidim_initiatives.initiatives_path(locale: I18n.locale) }
  let(:title) { "My space" }
  let(:participatory_space) { initiative }

  # We cannot use the shared example "manage participatory space publications"
  # as Initiatives have some differences in comparison with the other spaces:
  #
  # - Initiatives are not published/unpublished, they are validated
  # - There is a modal to confirm the publish/unpublish
  # - The public collection path is still visible even though there are not initiatives
  # - The initiative is visible for administrators even when it is unpublished
  #
  # That is why I copied and adapted that shared example to this file.

  describe "manage initiative publications" do
    before do
      participatory_space.update(title: { en: title })
      switch_to_host(organization.host)
      login_as user, scope: :user
    end

    context "when the participatory space is unpublished" do
      before do
        participatory_space.unpublish!
        participatory_space.reload
        visit admin_page_path
      end

      it "publishes it" do
        click_on "Publish"

        within "#confirm-modal" do
          click_on "OK"
        end

        expect(page).to have_content("successfully")

        visit public_collection_path

        expect(page).to have_content title
      end
    end

    context "when the participatory space is published" do
      before do
        allow(Rails.application).to \
          receive(:env_config).with(no_args).and_wrap_original do |m, *|
            m.call.merge(
              "action_dispatch.show_exceptions" => true,
              "action_dispatch.show_detailed_exceptions" => false
            )
          end
        participatory_space.publish!
        participatory_space.reload
        visit admin_page_path
      end

      it "unpublishes it" do
        # we cannot use "a 404 page" shared example as we want to check it
        # inside an example
        click_on "Unpublish"

        within "#confirm-modal" do
          click_on "OK"
        end

        expect(page).to have_content("successfully")

        visit public_collection_path

        expect(page).to have_no_content title
      end
    end
  end

  it "displays the entry in last activities" do
    participatory_space.update(title: { en: title })

    switch_to_host(organization.host)
    login_as user, scope: :user
    visit admin_page_path
    click_on "Publish"

    within "#confirm-modal" do
      click_on "OK"
    end

    visit decidim.last_activities_path
    expect(page).to have_content("New initiative: #{title}")

    within "#filters" do
      find("a", class: "filter", text: "Initiative", match: :first).click
    end
    expect(page).to have_content("New initiative: #{title}")
  end
end
