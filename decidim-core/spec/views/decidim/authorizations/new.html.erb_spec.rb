# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe "decidim/authorizations/new" do
    let(:handler) do
      DummyAuthorizationHandler.new({})
    end

    before do
      view.extend AuthorizationFormHelper
      view.extend DecidimFormHelper
      allow(view).to receive(:handler).and_return(handler)
      allow(view).to receive(:authorizations_path).and_return("/authorizations")
    end

    context "when there's a partial to render the form" do
      before do
        filepath = File.join(Dir.pwd, "/app/views/", handler.to_partial_path).split("/")
        filename = "_" + filepath.pop + ".html.erb"
        @filepath = filepath.join("/")
        FileUtils.mkdir_p(@filepath)
        File.open(File.join(filepath, "/", filename), "w") { |file| file.write("Custom partial") }
      end

      after do
        FileUtils.rm_rf(@filepath)
      end

      it "renders the form with the partial" do
        expect(render).to include("Custom partial")
      end
    end
  end
end
