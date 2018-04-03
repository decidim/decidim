# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe InitiativesType do
    let(:initiatives_type) { build :initiatives_type }

    it "is valid" do
      expect(initiatives_type).to be_valid
    end
  end
end
