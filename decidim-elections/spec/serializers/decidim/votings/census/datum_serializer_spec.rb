# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Census
      describe DatumSerializer do
        subject do
          described_class.new(datum)
        end

        let!(:datum) { create(:datum, :with_access_code) }

        describe "#serialize" do
          let(:serialized) { subject.serialize }

          it "serializes the datum" do
            expect(serialized).to include(full_name: datum.full_name)
            expect(serialized).to include(full_address: datum.full_address)
            expect(serialized).to include(postal_code: datum.postal_code)
            expect(serialized).to include(access_code: datum.access_code)
          end
        end
      end
    end
  end
end
