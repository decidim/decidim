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

      %w(age background gender nationalities postal_code).each do |field|
        it "has a #{field} method" do
          expect(demo).to respond_to field.to_sym
        end

        it "calls decrypts on #{field} method" do
          expect(Decidim::AttributeEncryptor).to receive(:decrypt)
          demo.send(field.to_sym)
        end
      end
    end
  end
end
