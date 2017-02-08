require "spec_helper"

module Decidim
  module Attributes
    describe TimeWithZone do
      describe "coerce" do
        subject { described_class.build(TimeWithZone, {}).coerce(value) }

        context "when given a Time" do
          let(:value) { Time.current }

          it "returns the time" do
            expect(subject).to eq(value)
          end
        end

        context "when given a String" do
          let(:value) { "2017-02-01T15:00:00" }

          context "in a different timezone" do
            it "parses the String in the correct timezone" do
              Time.use_zone("CET") do
                expect(subject.utc.to_s).to eq("2017-02-01 14:00:00 UTC")
              end
            end
          end

          context "but it is not valid" do
            let(:value) { "foo" }

            it "returns nil" do
              expect(subject).to eq(nil)
            end
          end
        end
      end
    end
  end
end
