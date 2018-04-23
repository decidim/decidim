# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe InitiativesTypeScope do
    let(:initiatives_type_scope) { build :initiatives_type_scope }

    it "is valid" do
      expect(initiatives_type_scope).to be_valid
    end
  end
end
