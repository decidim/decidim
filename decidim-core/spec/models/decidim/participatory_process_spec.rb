# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe ParticipatoryProcess do
    let(:process) { build(:process) }

    it "is valid" do
      expect(process).to be_valid
    end
  end
end
