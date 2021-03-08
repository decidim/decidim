# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin::Import::Readers
  describe Base do
    let(:subject) { described_class.new(file) }
    let(:file) { Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf") }

    describe "when abstract class tries to read rows" do
      it "raises not implemented" do
        expect { subject.read_rows }.to raise_error(NotImplementedError)
      end
    end
  end
end
