# frozen_string_literal: true

shared_examples "an authorization handler" do
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
