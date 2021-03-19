# frozen_string_literal: true

module Decidim
  module CellMatchers
    RSpec::Matchers.define :render_nothing do |_expected_value|
      match do |actual_value|
        expect(actual_value).to have_no_selector("html")
      end

      diffable
    end
  end
end

RSpec.configure do |config|
  config.include Decidim::CellMatchers, type: :cell
end
