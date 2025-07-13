# frozen_string_literal: true

shared_examples "etiquette validator" do |options|
  options[:fields].map(&:to_sym).each do |field|
    let!(field) { options[:i18n] ? { en: string } : string }

    context "when #{field} contains too many caps" do
      let(:string) { "#{"A" * 50}#{"a" * 49}" }

      it { is_expected.to be_invalid }
    end

    context "when #{field} not starting with caps" do
      let(:string) { "aa#{"A" * 50}#{"a" * 49}" }

      it { is_expected.to be_invalid }
    end

    context "when #{field} containing too many marks" do
      let(:string) { "#{"A" * 5}#{"a" * 49}!!??" }

      it { is_expected.to be_invalid }
    end
  end
end
