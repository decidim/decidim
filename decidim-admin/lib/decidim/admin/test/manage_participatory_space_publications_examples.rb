# frozen_string_literal: true

shared_examples "manage participatory space publications" do |_options|
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
      click_link "Publish"

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
      click_link "Unpublish"

      expect(page).to have_content("successfully")

      visit public_collection_path

      expect(page).to have_content("The page you are looking for cannot be found")
    end
  end
end
