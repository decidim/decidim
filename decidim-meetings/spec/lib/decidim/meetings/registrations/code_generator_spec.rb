# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    module Registrations
      describe CodeGenerator do
        subject { described_class.new(length:) }

        let(:length) { 6 }
        let(:meeting) { build(:meeting) }
        let(:registration) { build :registration, meeting: }

        describe "#generate" do
          let(:existing_code) { "AS35TY58" }
          let(:valid_code) { "QW89HJ34" }
          let(:code) { subject.generate(registration) }

          before do
            create :registration, meeting: meeting, code: existing_code
            expect(subject)
              .to receive(:choose)
              .with(length)
              .twice
              .and_return(existing_code, valid_code)
          end

          it "returns an unique code" do
            expect(code).to eq valid_code
          end
        end

        describe "#choose" do
          let(:code) { subject.generate(registration) }

          it "returns a code with correct length" do
            expect(code.length).to eq(length)
          end

          it "returns a code where all chars are valid" do
            code.chars.each do |char|
              expect(CodeGenerator::ALPHABET).to include char
            end
          end
        end
      end
    end
  end
end
