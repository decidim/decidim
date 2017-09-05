# frozen_string_literal: true

require "spec_helper"

describe Decidim::Notification, :db do
  let(:notification) { build(:notification) }
  subject { notification }

  it { is_expected.to be_valid }

  context "validations" do
    context "without user" do
      let(:notification) { build(:notification, user: nil) }

      it { is_expected.not_to be_valid }
    end

    context "without resource" do
      let(:notification) { build(:notification, resource: nil) }

      it { is_expected.not_to be_valid }
    end
  end
end
