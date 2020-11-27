# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Demographics
    describe RegisterDemographicsData do
      subject { described_class.new(demographic, form) }

      let(:form) do
        double(
          invalid?: validity,
          attributes: {
            age: " < 15"
          }
        )
      end
      let(:demographic) do
        double(
          data: {
            age: "< 15"
          }
        )
      end

      describe "call" do
        describe "when invalid" do
          let(:validity) { true }

          it "broadcasts invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        describe "when valid" do
          let(:validity) { false }

          it "broadcasts ok" do
            expect(demographic).to receive(:save!)
            expect { subject.call }.to broadcast(:ok)
          end
        end
      end
    end
  end
end
