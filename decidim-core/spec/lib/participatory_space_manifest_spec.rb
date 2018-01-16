# frozen_string_literal: true

# rubocop:disable RSpec/EmptyExampleGroup

require "spec_helper"

module Decidim
  describe ParticipatorySpaceManifest do
    subject { described_class.new }

    describe "#context" do
      it "defines and caches contexts" do
        subject.context(:context1) do |context|
          context.layout = "layouts/context1"
        end

        subject.context(:context2) do |context|
          context.layout = "layouts/context2"
        end

        expect(subject.context(:context1).layout).to eq("layouts/context1")
        expect(subject.context(:context2).layout).to eq("layouts/context2")
      end
    end
  end
end
