# frozen_string_literal: true

require "spec_helper"

describe Decidim::ReminderGeneratorJob do
  subject { described_class.perform_now(generator_class) }

  let(:generator_class) do
    double(
      constantize: constantized_class,
      generate: double
    )
  end

  let(:constantized_class) do
    double(
      new: generator
    )
  end

  let(:generator) { double }

  context "when there is generator class" do
    describe "#perform" do
      it "creates generator and calls generate" do
        expect(generator).to receive(:generate)

        subject
      end
    end
  end
end
