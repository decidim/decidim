# frozen_string_literal: true

shared_examples "etiquette validator" do |options|
  options[:fields].map(&:to_sym).each do |field|
    context "when #{field} contains too many caps" do
      let(field) do
        string = "#{"A" * 50}#{"a" * 49}"
        options[:i18n].true?  == false ? string : { en: string }
      end

      it { is_expected.to be_invalid }
    end

    context "when #{field} not starting with caps" do
      let(field) do
        string = "aa#{"A" * 50}#{"a" * 49}"
        options[:i18n] == false ? string : { en: string }
      end

      it { is_expected.to be_invalid }
    end

    context "when #{field} containing too many marks" do
      let(field) do
        string = "#{"A" * 5}#{"a" * 49}!!??"
        options[:i18n] == false ? string : { en: string }
      end

      it { is_expected.to be_invalid }
    end
  end
end
