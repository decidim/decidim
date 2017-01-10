# frozen_string_literal: true
RSpec.shared_examples "an authorization handler" do
  before do
    unless respond_to?(:handler)
      raise "You need to define `handler` (an instance of the authorization handler) in order to run the shared examples."
    end
  end

  describe "authorized?" do
    it "is implemented" do
      expect do
        handler.authorized?
      end.to_not raise_error
    end
  end

  describe "to_partial_path" do
    subject { handler.to_partial_path }
    it { is_expected.to be_kind_of(String) }
  end

  describe "handler_name" do
    subject { handler.handler_name }
    it { is_expected.to be_kind_of(String) }
  end

  describe "metadata" do
    subject { handler.metadata }
    it { is_expected.to be_kind_of(Hash) }
  end
end
