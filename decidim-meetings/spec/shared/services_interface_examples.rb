# frozen_string_literal: true

require "spec_helper"

shared_examples_for "services interface" do
  describe "services" do
    let(:query) { '{ services { title { translation(locale:"en") } description { translation(locale:"en") } } }' }

    describe "when services is not present" do
      it "does not include the services" do
        expect(response["services"]).to eq([])
      end
    end

    describe "with some services" do
      let(:model) { create :meeting, :with_services }
      let(:services) { model.services }

      it "includes the required data" do
        expect(response["services"].first["title"]["translation"])
          .to eq(services.first["title"]["en"])
        expect(response["services"].first["description"]["translation"])
          .to eq(services.first["description"]["en"])
      end
    end
  end
end
