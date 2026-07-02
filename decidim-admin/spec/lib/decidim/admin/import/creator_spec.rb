# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin::Import
  describe Creator do
    subject { described_class.new(unknown_resource) }
    let(:unknown_resource) { { field: "foo" } }

    describe ".batch_notifier_klass" do
      it "returns nil by default" do
        expect(described_class.batch_notifier_klass).to be_nil
      end
    end

    it "cannot finish without implementation for a resource" do
      expect { subject.finish! }.to raise_error(NotImplementedError)
    end

    it "delegates finish_without_notify! to finish!" do
      expect { subject.finish_without_notify! }.to raise_error(NotImplementedError)
    end
  end
end
