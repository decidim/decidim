# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MetricOperation do
    subject { described_class.new }

    describe "register" do
      it "registers a metric" do
        register_metric(:dummy_operation, :users)

        expect(subject.for(:dummy_operation, :users).try(:metric_name)).to eq "users"
      end

      it "raises an error if the content block is already registered" do
        register_metric(:dummy_operation, :users)

        expect { register_metric(:dummy_operation, :users) }
          .to raise_error(described_class::MetricOperationAlreadyRegistered)
      end
    end

    describe "for(:scope)" do
      it "returns all metrics for that scope" do
        register_metric(:dummy_operation, :users)
        register_metric(:dummy_operation, :more_users)
        register_metric(:dummy_operation2, :no_users)

        expect(subject.for(:dummy_operation).map(&:metric_name)).to eq %w(users more_users)
      end
    end

    def register_metric(operation, name)
      subject.register(operation, name) do |metric_registry|
        metric_registry.manager_class = "Decidim::#{name.capitalize}Operation"
      end
    end
  end
end
