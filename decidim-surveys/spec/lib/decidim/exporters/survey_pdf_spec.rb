# frozen_string_literal: true

require "spec_helper"

load "decidim/exporters/form_pdf"

module Decidim
  describe Exporters::FormPDF do
    # include Decidim::TranslationsHelper

    subject do
      described_class.new(participants, Decidim::Forms::UserAnswersSerializer)
    end

    let(:questionnaire) { create(:questionnaire) }
    let(:participants) { 5.times.map { create_list(:answer, 5, questionnaire: questionnaire) } }

    describe "#export" do
      it "exports the collection to a pdf" do
        export_data = subject.export
        expect(export_data.read).to match("%PDF-1.4")
      end
    end
  end
end
