# frozen_string_literal: true

shared_examples "delete old versions job" do
  context "when a valid cutoff days argument is provided" do
    context "with zero" do
      let(:cutoff_days) { 0 }

      it "does not raise" do
        expect { subject }.not_to raise_error
      end
    end
  end

  context "when an invalid cutoff days argument is provided" do
    subject { described_class.perform_now(cutoff_days) }

    context "with a negative value" do
      let(:cutoff_days) { -1 }

      it "raises InvalidArgument" do
        expect { subject }.to raise_error(described_class::InvalidArgument)
      end
    end

    context "with a Float" do
      let(:cutoff_days) { 1.2 }

      it "raises InvalidArgument" do
        expect { subject }.to raise_error(described_class::InvalidArgument)
      end
    end

    context "with a String" do
      let(:cutoff_days) { "20" }

      it "raises InvalidArgument" do
        expect { subject }.to raise_error(described_class::InvalidArgument)
      end
    end
  end
end
