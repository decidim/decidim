# frozen_string_literal: true

require "spec_helper"

module Decidim::System
  describe FileUploadSettingsForm do
    subject do
      described_class.from_model(model)
    end

    let(:defaults) { Decidim::OrganizationSettings.default(:upload) }

    describe "#map_model" do
      context "when the model is not a hash" do
        let(:model) { double }

        it "sets the default settings for the view" do
          expect(subject.allowed_file_extensions).to eq(
            defaults["allowed_file_extensions"].map { |k, v| [k.to_sym, v.join(",")] }.to_h
          )
          expect(subject.allowed_content_types).to eq(
            defaults["allowed_content_types"].map { |k, v| [k.to_sym, v.join(",")] }.to_h
          )
          expect(subject.maximum_file_size).to eq(
            defaults["maximum_file_size"].map { |k, v| [k.to_sym, v.to_f] }.to_h
          )
        end
      end
    end
  end
end
