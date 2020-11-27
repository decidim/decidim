# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Demographics
    describe Demographic do
      let!(:demo) { FactoryBot.create(:demographic) }

      it "belongs to a user" do
        expect(demo).to respond_to :user
      end

      it "belongs to a organization" do
        expect(demo).to respond_to :organization
      end

      %w(gender age nationalities other_nationalities residences other_residences living_condition current_occupations education_age_stop other_ocupations attended_before newsletter_sign_in).each do |field|
        it "has a #{field} method" do
          expect(demo).to respond_to field.to_sym
        end
      end
    end
  end
end
