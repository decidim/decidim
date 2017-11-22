# frozen_string_literal: true

shared_examples_for "a 404 page" do
  describe "visiting the page", driver: :rack_test do
    before do
      allow(Rails.application).to \
        receive(:env_config).with(no_args).and_wrap_original do |m, *|
          m.call.merge(
            "action_dispatch.show_exceptions" => true,
            "action_dispatch.show_detailed_exceptions" => false
          )
        end

      visit target_path
    end

    it "leads to a 404" do
      expect(page).to have_content("The page you're looking for can't be found")

      expect(page).to have_http_status(:not_found)
    end
  end
end
