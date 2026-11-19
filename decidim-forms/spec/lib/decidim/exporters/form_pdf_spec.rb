# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Exporters::FormPDF do
    subject do
      described_class.new(participants, Decidim::Forms::UserResponsesSerializer)
    end

    let(:questionnaire) { create(:questionnaire) }
    let(:participants) { 5.times.map { create_list(:response, 5, questionnaire:) } }

    describe "#export" do
      it "exports the collection to a pdf" do
        export_data = subject.export
        expect(export_data.read).to match("%PDF-1.5")
      end

      context "when the collection is empty" do
        let(:participants) { [] }

        it "exports an empty pdf" do
          export_data = subject.export
          expect(export_data.read).to match("%PDF-1.5")
          expect(export_data.extension).to eq("pdf")
        end
      end
    end
  end
end
