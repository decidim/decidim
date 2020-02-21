# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe Filterable do
      class FilterableTester < DecidimController
        include Decidim::Admin::Filterable
      end

      context "when not overriding the #base_query" do
        let(:tester) { FilterableTester.new }

        it "raises NotImplementedException" do
          expect { tester.query }.to raise_error(NotImplementedError)
        end
      end
    end
  end
end
