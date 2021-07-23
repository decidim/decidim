# frozen_string_literal: true

require "spec_helper"

describe Decidim::OpenDataJob do
  subject { described_class }

  let(:organization) { create(:organization) }

  describe "perform" do
    before do
      organization.open_data_file.purge
    end

    it "uploads the generated file" do
      expect { subject.perform_now(organization) }.to change { organization.open_data_file.attached? }.from(false).to(true)
    end
  end
end
