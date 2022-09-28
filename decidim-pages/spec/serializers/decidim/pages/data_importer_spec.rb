# frozen_string_literal: true

require "spec_helper"

module Decidim::Pages
  describe DataImporter do
    let(:importer) { described_class.new(component) }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, :confirmed, organization:) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:component) { create(:component, manifest_name: "pages", participatory_space: participatory_process) }

    describe "#import" do
      subject { importer.import(as_json, user) }

      let(:as_json) do
        JSON.parse(
          <<~JSON
            {
              "body": {
                "en": "English content",
                "ca": "Catalan content",
                "es": "Spanish content"
              }
            }
          JSON
        )
      end

      it "imports the page" do
        expect(subject).to be_a(Decidim::Pages::Page)
        expect(subject.id).to eq(Page.find_by(component:).id)
        expect(subject.body).to eq(
          {
            "en" => "English content",
            "ca" => "Catalan content",
            "es" => "Spanish content"
          }
        )
      end
    end
  end
end
