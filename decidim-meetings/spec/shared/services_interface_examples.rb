# frozen_string_literal: true

require "spec_helper"

shared_examples_for "services interface" do
  describe "services" do
    let(:query) { '{ services { title { translation(locale:"en") } description { translation(locale:"en") } } }' }

    before do
      model.update(services: services)
    end

    describe "when services is not present" do
      let(:services) { nil }

      it "does not include the services" do
        expect(response["services"]).to eq([])
      end
    end

    describe "with some services" do
      let(:services) do
        [{
          title: {
            en: "Some title service"
          },
          description: {
            en: "Some description service"
          }
        }]
      end

      it "includes the required data" do
        expect(response["services"].first["title"]["translation"]).to eq(services.first[:title][:en])
        expect(response["services"].first["description"]["translation"]).to eq(services.first[:description][:en])
      end
    end
  end
end
