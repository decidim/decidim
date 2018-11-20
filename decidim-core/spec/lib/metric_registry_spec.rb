# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MetricRegistry do
    subject { described_class.new }

    describe "register" do
      it "registers a metric" do
        register_metric(:users)

        expect(subject.for(:users).try(:metric_name)).to eq "users"
      end

      it "raises an error if the content block is already registered" do
        register_metric(:users)

        expect { register_metric(:users) }
          .to raise_error(described_class::MetricAlreadyRegistered)
      end
    end

    def register_metric(name)
      subject.register(name) do |metric_registry|
        metric_registry.manager_class = "Decidim::#{name.capitalize}"
      end
    end
  end
end
