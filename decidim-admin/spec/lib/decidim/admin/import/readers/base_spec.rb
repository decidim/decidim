# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin::Import::Readers
  describe Base do
    subject { described_class.new(file) }
    let(:file) { Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf") }

    describe "#read_rows" do
      it "raises not implemented" do
        expect { subject.read_rows }.to raise_error(NotImplementedError)
      end
    end

    describe "#example_file" do
      it "raises not implemented" do
        expect { subject.example_file([]) }.to raise_error(NotImplementedError)
      end
    end
  end
end
