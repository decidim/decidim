require "spec_helper"

describe Decidim::Admin::ReorderParticipatoryProcessSteps do
  let(:process) { create :participatory_process }
  let!(:process_step1) do
    create(
      :participatory_process_step,
      participatory_process: process,
      position: 1
    )
  end
  let!(:process_step2) do
    create(
      :participatory_process_step,
      participatory_process: process,
      position: 2
    )
  end
  let(:collection) { process.steps }
  let(:order_string) { "[#{process_step2.id}, #{process_step1.id}]" }

  subject { described_class.new(collection, order_string) }

  context "when the order_string is nil" do
    let(:order_string) { nil }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the order_string is not an array string" do
    let(:order_string) { "something_something" }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the order_string is an empty array string" do
    let(:order_string) { "[]" }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the order_string is valid" do
    it "is valid" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "deactivates it" do
      subject.call
      process_step1.reload
      process_step2.reload
      expect(process_step1.position).to eq 1
      expect(process_step2.position).to eq 0
    end
  end
end
