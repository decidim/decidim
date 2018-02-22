# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Search do
    describe "call" do
      let(:current_organization) { create(:organization) }

      context "whith resources from different organizations" do
        let(:other_organization) { create(:organization)}
        before do
          create(:searchable_rsrc, organization: current_organization, content_a: "Fight fire with fire")
          create(:searchable_rsrc, organization: other_organization, content_a: "Light my fire")
        end
        let(:term) {"fire"}

        it "should return resources only from current_organization" do
          described_class.call(term, current_organization) do
            on(:ok) {|results|
              expect(results.count).to eq(1)
              expect(results.first.organization).to eq(current_organization)
            }
            on(:invalid) {fail("Should not happen")}
          end
        end
      end

      context "when SearchRsrc is empty" do
        let(:term) { 'whatever' }

        it "should return an empty list" do
          described_class.call(term, current_organization) do
            on(:ok) do |results|
              expect(results).to be_empty
            end
            on(:invalid) {fail("Should not happen")}
          end
        end
      end

      context "when 'term' param is empty" do
        let(:term) { '' }
        before do
          create(:searchable_rsrc, organization: current_organization)
        end
        it "should return some random results" do
          described_class.call(term, current_organization) do
            on(:ok) {|results|
              expect(results).not_to be_empty
            }
            on(:invalid) {fail("Should not happen")}
          end
        end
      end

      context "when filtering by resource type" do
        let(:term) { 'king nothing' }
        let(:rsrc_type) { 'Decidim::Meetings::Meeting' }
        before do
          create(:searchable_rsrc, organization: current_organization, resource_type: rsrc_type, content_a: "Where's your crown king nothing?")
          create(:searchable_rsrc, organization: current_organization, resource_type: "Decidim::Proposals::Proposal", content_a: "Where's your crown king nothing?")
        end

        it "should only return resources of the given type" do
          described_class.call(term, current_organization, resource_type: rsrc_type) do
            on(:ok) {|results|
              expect(results).not_to be_empty
              expect(
                results.all? {|r| r.resource_type == rsrc_type }
              ).to be true
            }
            on(:invalid) {fail("Should not happen")}
          end
        end
      end
    end
  end
end
