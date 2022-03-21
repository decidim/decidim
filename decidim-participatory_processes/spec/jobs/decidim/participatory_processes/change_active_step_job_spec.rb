# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryProcesses::ChangeActiveStepJob do
  subject { described_class }

  describe "queue" do
    it "is queued to events" do
      expect(subject.queue_name).to eq "default"
    end
  end
end
