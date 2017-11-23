# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Abilities
    describe EveryoneAbility do
      subject { described_class.new(user, {}) }

      let(:user) { build(:user) }

      it "lets the user read processes" do
        expect(subject.permissions[:can][:read]).to include("public_pages")
      end
    end
  end
end
