# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Authorization, :db do
    let(:authorization) { build(:authorization) }

    it "is valid" do
      expect(authorization).to be_valid
    end
  end
end
