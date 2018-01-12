# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe "decidim/verifications/authorizations/new" do
    let(:handler) do
      DummyAuthorizationHandler.new({})
    end
    let(:organization) { double(cta_button_path: "/") }

    before do
      view.extend AuthorizationFormHelper
      view.extend DecidimFormHelper
      view.extend CtaButtonHelper
      allow(view).to receive(:current_organization).and_return(organization)
      allow(view).to receive(:handler).and_return(handler)
      allow(view).to receive(:params).and_return(handler: "dummy_authorization_handler")
      allow(view).to receive(:authorizations_path).and_return("/authorizations")
      allow(view).to receive(:stored_location).and_return("/processes")
    end

    context "when there's a partial to render the form" do
      around do |example|
        filepath = File.join(Dir.pwd, "/app/views/", handler.to_partial_path).split("/")
        filename = "_" + filepath.pop + ".html.erb"
        filepath = filepath.join("/")
        FileUtils.mkdir_p(filepath)
        File.open(File.join(filepath, "/", filename), "w") { |file| file.write("Custom partial") }

        example.run

        FileUtils.rm_rf(filepath)
      end

      it "renders the form with the partial" do
        expect(render).to include("Custom partial")
      end
    end
  end
end
