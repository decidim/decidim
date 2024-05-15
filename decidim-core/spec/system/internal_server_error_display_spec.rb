# frozen_string_literal: true

require "spec_helper"

describe "Internal server error display" do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, :confirmed, name: "Sarah Kerrigan", organization:) }
  let(:controller) do
    Class.new(Decidim::ApplicationController) do
      def show
        request.env["action_dispatch.show_exceptions"] = true
        request.env["action_dispatch.show_detailed_exceptions"] = false

        # This should generate an undefined constant error
        FooBar
      end
    end
  end

  before do
    Decidim.send(:remove_const, :HomepageController) if Decidim.const_defined?(:HomepageController)
    Decidim.const_set(:HomepageController, controller)
    switch_to_host(organization.host)
    allow(Time).to receive(:current).and_return("01/01/2022 - 12:00".to_time)
  end

  after do
    Decidim.send(:remove_const, :HomepageController)
    load "#{Decidim::Core::Engine.root}/app/controllers/decidim/homepage_controller.rb"
  end

  describe "form genereation" do
    before do
      visit "/"
    end

    it "generates the copiable form" do
      expect(page).to have_content("Please try again later. If the error persists, please copy the following info and send it to platform maintainers with any other information you may want to share.")
      within "tr", text: "User ID" do
        expect(page).to have_content("Unknown")
      end
      within "tr", text: "Date and time" do
        expect(page).to have_content("2022-01-01T12:00:00.000000")
      end
      within "tr", text: "URL" do
        expect(page).to have_content("http://#{organization.host}:#{Capybara.server_port}")
      end
      within "tr", text: "Request method" do
        expect(page).to have_content("GET")
      end
      expect(page).to have_button("Copy to clipboard")
    end
  end

  context "with log in as a user" do
    before do
      login_as user, scope: :user
      visit "/"
    end

    it "displays the user ID" do
      within "tr", text: "User ID" do
        expect(page).to have_content(user.id)
      end
    end

    context "when clicking copy link button" do
      before do
        visit "/"
        click_on "Copy to clipboard"
      end

      it "copies the data to the clipboard" do
        expect(page).to have_content("Text copied!")
      end
    end
  end

  describe "generate reference" do
    before do
      allow(Rails.application.config).to receive(:log_level).and_return(:error)
      allow(Rails.application.config).to receive(:log_formatter).and_return(Logger::Formatter.new)
      allow(Rails.application.config).to receive(:log_tags).and_return([->(request) { "dummy changes-#{request.request_id}" }, :request_id, "normal_string"])
      visit "/"
    end

    it "generates the reference" do
      within "tr", text: "Reference" do
        expect(page).to have_content(/\[dummy changes-(\w+['-])+\w+\] \[(\w+['-]+)+\w+\] \[normal_string\]$/)
      end
    end
  end
end
