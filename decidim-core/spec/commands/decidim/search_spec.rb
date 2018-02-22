# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Search do
    describe "call" do
      let(:organization) { create(:organization) }
      let(:command) { described_class.new(term) }

      context "when SearchRsrc is empty" do
        let(:term) { "whathever" }

        it "should return an empty list" do
          expect(command.call).to broadcast(:ok, [])
        end
      end
      context "when 'term' param is empty" do
        let(:term) { '' }
        before do
          create(:searchable_rsrc)
        end
        it "should return some random results" do
          rs= described_class.call(term) do
            on(:ok) {|results|
              expect(results).not_to be_empty
            }
            on(:invalid) {fail("Should not happen")}
          end
        end
      end
    end
  end
end
