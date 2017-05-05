# frozen_string_literal: true
require "spec_helper"

describe Decidim::Admin::UnpublishParticipatoryProcess do
  let(:my_process) { create :participatory_process }

  subject { described_class.new(my_process) }

  context "when the process is nil" do
    let(:my_process) { nil }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the process is not published" do
    let(:my_process) { create :participatory_process, :unpublished }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the process is published" do
    it "is valid" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "unpublishes it" do
      subject.call
      my_process.reload
      expect(my_process).not_to be_published
    end
  end
end
