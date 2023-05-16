# frozen_string_literal: true

shared_examples_for "clean engine" do
  described_class.initializers.each do |initializer|
    describe "'#{initializer.name}' initializer" do
      let(:initializer_name_prefix) { described_class.to_s.sub(/::([A-Za-z]+)?Engine$/, "\\1").gsub("::", "").underscore }

      it "is named correctly" do
        expect(initializer.name).to start_with("#{initializer_name_prefix}.")
        expect(initializer.name).to match(/^[a-z0-9_.]+$/)
        expect(initializer.name).not_to start_with(".")
      end
    end
  end
end
