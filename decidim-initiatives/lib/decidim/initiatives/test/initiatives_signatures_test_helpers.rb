# frozen_string_literal: true

module Decidim
  module Initiatives
    module InitiativesSignaturesTestHelpers
      def fill_signature_date(date)
        [date.year, date.month, date.day].each_with_index do |value, i|
          within "select[name='dummy_signature_handler[date_of_birth(#{i + 1}i)]']" do
            find("option[value='#{value}']").select_option
          end
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include Decidim::Initiatives::InitiativesSignaturesTestHelpers, type: :system
end
