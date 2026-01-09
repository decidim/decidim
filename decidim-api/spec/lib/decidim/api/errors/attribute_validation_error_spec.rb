# frozen_string_literal: true

require "spec_helper"
require "active_model"

module Decidim
  module Api
    module Errors
      describe AttributeValidationError do
        subject { described_class.new(messages) }
        let(:messages) { [] }

        context "when initialized with an Array of hashes" do
          let(:messages) do
            [
              {
                path: %w(attributes body),
                message: "is too short (under 15 characters)"
              },
              {
                path: %w(attributes title),
                message: "is too long"
              }
            ]
          end

          describe "#to_h" do
            it { expect(subject.to_h).to include("extensions" => { "code" => "ATTRIBUTE_VALIDATION_ERROR" }) }
            it { expect(subject.to_h).to include("message" => messages) }
          end

          describe "#message" do
            it { expect(subject.message).to eq("is too short (under 15 characters), is too long") }
          end
        end

        context "when initialized with ActiveModel::Errors" do
          let(:dummy_model_class) do
            Class.new do
              include ActiveModel::Model

              attr_accessor :body, :title

              validates :body, presence: true
              validates :title, presence: true

              def self.name
                "DummyModel"
              end
            end
          end
          let(:messages) do
            model = dummy_model_class.new
            model.errors.add(:body, :too_short, count: 15)
            model.errors.add(:title, :too_long, count: 1)
            model.errors
          end

          describe "#to_h" do
            it { expect(subject.to_h).to include("extensions" => { "code" => "ATTRIBUTE_VALIDATION_ERROR" }) }

            it {
              expect(subject.to_h).to include("message" => [
                                                {
                                                  path: %w(attributes body),
                                                  message: "is too short (under 15 characters)"
                                                },
                                                {
                                                  path: %w(attributes title),
                                                  message: "is too long (maximum is 1 character)"
                                                }
                                              ])
            }
          end

          describe "#message" do
            it { expect(subject.message).to include("is too short (under 15 characters)") }
            it { expect(subject.message).to include("is too long") }
          end
        end
      end
    end
  end
end
