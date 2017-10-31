# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Events::BaseEvent do
    describe ".types" do
      subject { described_class }

      it "returns an empty array" do
        expect(subject.types).to eq []
      end
    end
  end
end
