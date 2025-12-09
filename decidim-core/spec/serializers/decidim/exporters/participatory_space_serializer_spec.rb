# frozen_string_literal: true

require "spec_helper"
require "json"

module Decidim::Exporters
  describe ParticipatorySpaceSerializer do
    subject { described_class.new(resource) }

    let(:resource) { create(:participatory_process) }
    let(:serialized) { subject.serialize }

    describe "#serialize" do
      it "includes the component settings of that space" do
        expect(serialized).to include(:component_settings)
      end

      it "creates a column of settings in a JSON format" do
        expect { serialized[:component_settings].to_json }.not_to raise_error(::JSON::GeneratorError)
      end
    end
  end
end
