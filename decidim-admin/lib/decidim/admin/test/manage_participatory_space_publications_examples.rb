# frozen_string_literal: true

shared_examples "manage participatory space publications" do
  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit admin_page_path
  end

  context "when the participatory space is unpublished" do
    before do
      participatory_space.unpublish!
      participatory_space.reload
      visit admin_page_path

      within("tr", text: translated_attribute(participatory_space.title)) do
        find("button[data-component='dropdown']").click
        find("a", text: "Publish", visible: true).click
      end
    end

    it "publishes it" do
      expect(page).to have_content("successfully")

      visit public_collection_path

      expect(page).to have_content(translated_attribute(participatory_space.title))
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
      within("tr", text: translated_attribute(participatory_space.title)) do
        find("button[data-component='dropdown']").click
        click_on "Unpublish"
      end

      expect(page).to have_content("successfully")

      visit public_collection_path

      expect(page).to have_content("The page you are looking for cannot be found")
    end
  end
end
