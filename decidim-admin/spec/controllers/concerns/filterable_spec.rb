# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    class FilterableTester < DecidimController
      include Decidim::Admin::Filterable
    end

    describe Filterable do
      context "when not overriding the #base_query" do
        let(:tester) { FilterableTester.new }

        it "raises NotImplementedException" do
          expect { tester.query }.to raise_error(NotImplementedError)
        end
      end
    end
  end
end
