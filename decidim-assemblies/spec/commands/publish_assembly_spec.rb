# frozen_string_literal: true

require "spec_helper"

describe Decidim::Assemblies::Admin::PublishAssembly do
  let(:my_assembly) { create :assembly, :unpublished }

  subject { described_class.new(my_assembly) }

  context "when the assembly is nil" do
    let(:my_assembly) { nil }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the assembly is published" do
    let(:my_assembly) { create :assembly }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the assembly is not published" do
    it "is valid" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "publishes it" do
      subject.call
      my_assembly.reload
      expect(my_assembly).to be_published
    end
  end
end
