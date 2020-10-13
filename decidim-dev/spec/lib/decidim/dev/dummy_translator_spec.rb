# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DummyTranslator do
    subject { described_class.new(resource, field_name, original_value, target_locale, source_locale) }

    let(:resource) { create :participatory_process, title: { source_locale => original_value } }
    let(:source_locale) { :en }
    let(:target_locale) { :ca }
    let(:field_name) { :title }
    let(:original_value) { "My title" }

    it "schedules a job to save the attribute" do
      expect(MachineTranslationSaveJob)
        .to receive(:perform_later)
        .with(
          resource,
          field_name,
          target_locale,
          "#{target_locale} - #{original_value}"
        )

      subject.translate
    end
  end
end
