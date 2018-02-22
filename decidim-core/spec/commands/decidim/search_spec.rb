# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Search do
    describe "call" do
      let(:current_organization) { create(:organization) }
      let(:command) { described_class.new(term, current_organization) }

      context "whith resources from different organizations" do
        let(:other_organization) { create(:organization)}
        before do
          create(:searchable_rsrc, organization: current_organization, content_a: "Fight fire with fire")
          create(:searchable_rsrc, organization: other_organization, content_a: "Light my fire")
        end
        let(:term) {"fire"}

        it "should return resources only from current_organization" do
          rs= command.call do
            on(:ok) {|results|
              expect(results.count).to eq(1)
              expect(results.first.organization).to eq(current_organization)
            }
            on(:invalid) {fail("Should not happen")}
          end
        end
      end
      context "when SearchRsrc is empty" do
        let(:term) { "whatever" }

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
          rs= command.call do
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
