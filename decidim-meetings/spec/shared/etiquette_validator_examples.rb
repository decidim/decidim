shared_examples "etiquette validator" do |options|
  options[:fields].map(&:to_sym).each do |field|
    context "when #{field} contains too many caps" do
      let(field) do
        if options[:i18n] == false
          "A" * 50 + "a" * 49
        else
          { en: "A" * 50 + "a" * 49 }
        end
      end
      it { is_expected.to be_invalid }
    end

    context "when #{field} not starting with caps" do
      let(field) do
        if options[:i18n] == false
          "aa" + "A" * 50 + "a" * 49
        else
          { en: "aa" + "A" * 50 + "a" * 49 }
        end
      end
      it { is_expected.to be_invalid }
    end

    context "when #{field} containing too many marks" do
      let(field) do
        if options[:i18n] == false
          "A" * 5 + "a" * 49 + "!!??"
        else
          { en: "A" * 5 + "a" * 49 + "!!??" }
        end
      end
      it { is_expected.to be_invalid }
    end
  end
end
