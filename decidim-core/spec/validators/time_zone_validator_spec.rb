# frozen_string_literal: true

require "spec_helper"

describe TimeZoneValidator do
  let(:validatable) do
    Class.new do
      def self.model_name
        ActiveModel::Name.new(self, nil, "Validatable")
      end

      include Virtus.model
      include ActiveModel::Validations

      attribute :time_zone

      validates :time_zone, time_zone: true
    end
  end

  let(:subject) { validatable.new(time_zone: time_zone) }

  context "when the time zone is valid" do
    let(:time_zone) { "Tijuana" }

    it "validates time zone" do
      expect(subject).to be_valid
    end
  end

  context "when the time_zone is not valid" do
    let(:time_zone) { "Arrakis" }

    it { is_expected.to be_invalid }
  end
end
