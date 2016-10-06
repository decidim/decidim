# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe Organization do
    let(:organization) { build(:organization) }

    it "is valid" do
      expect(organization).to be_valid
    end
  end
end
