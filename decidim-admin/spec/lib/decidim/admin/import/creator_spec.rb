# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin::Import
  describe Creator do
    subject { described_class.new(unknown_resource) }
    let(:unknown_resource) { { field: "foo" } }

    it "cant finish without implementation for a resource" do
      expect { subject.finish! }.to raise_error(NotImplementedError)
    end
  end
end
