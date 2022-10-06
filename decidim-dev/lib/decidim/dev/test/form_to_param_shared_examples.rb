# frozen_string_literal: true

shared_examples "form to param" do |options|
  method_name = options[:method_name] || :to_param

  describe "##{method_name}" do
    subject { described_class.new(id:) }

    context "with actual ID" do
      let(:id) { double }

      it "returns the ID" do
        expect(subject.public_send(method_name)).to be(id)
      end
    end

    context "with nil ID" do
      let(:id) { nil }

      it "returns the ID placeholder" do
        expect(subject.public_send(method_name)).to eq(options[:default_id])
      end
    end

    context "with empty ID" do
      let(:id) { "" }

      it "returns the ID placeholder" do
        expect(subject.public_send(method_name)).to eq(options[:default_id])
      end
    end
  end
end
