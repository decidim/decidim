# frozen_string_literal: true

require "spec_helper"

describe Decidim::JobWithAssets do
  let(:organization) { build(:organization) }

  shared_examples "changed current URL options with host" do
    it "sets the current URL options correctly" do
      subject
      expect(state_storage.before).to be_blank
      expect(state_storage.after).to eq(
        host: expected_host,
        port: Capybara.server_port
      )
    end
  end

  shared_examples "unchanged current URL options" do
    it "does not change the current URL options" do
      subject
      expect(state_storage.before).to eq(state_storage.after)
    end
  end

  shared_examples "working job with assets" do
    let(:job_target) { self.class.const_get(:DummyJob) }
    let(:state_storage) { Struct.new(:before, :after).new }
    let(:state_tracker) do
      # Hack needed to track the state before and after when the jobs are run
      # through the enqueued jobs (`#perform_later`). This is because the
      # reloader clears `ActiveStorage::Current.url_options` which would cause
      # it to be empty after the enqueued job has been performed.
      mod = Module.new do
        extend ActiveSupport::Concern

        included do
          before_perform :track_state_before
          after_perform :track_state_after
        end

        private

        def track_state_before
          state_storage.before = ActiveStorage::Current.url_options.dup
        end

        def track_state_after
          state_storage.after = ActiveStorage::Current.url_options.dup
        end

        def state_storage
          self.class::STORAGE
        end
      end
      mod.tap do |mod|
        mod.const_set(:STORAGE, state_storage)
      end
    end

    around do |example|
      self.class.const_set(:DummyJob, job_class)
      example.run
      self.class.send(:remove_const, :DummyJob)
    end

    context "with a positional argument named organization" do
      let(:job_class) do
        tracker = state_tracker
        mod = described_class
        Class.new(Decidim::ApplicationJob) do
          include tracker
          include mod

          def perform(first, second, organization, fourth); end
        end
      end
      let(:arguments) { ["first", "second", organization, "fourth"] }

      it_behaves_like "changed current URL options with host" do
        let(:expected_host) { organization.host }
      end

      context "when the argument value is not a Decidim::Organization" do
        let(:arguments) { ["first", "second", nil, "fourth"] }

        it_behaves_like "changed current URL options with host" do
          let(:expected_host) { "localhost" }
        end

        context "and default URL options do not define the host" do
          before { allow(Rails.env).to receive(:local?).and_return(false) }

          it_behaves_like "unchanged current URL options"
        end
      end
    end

    context "with alternatively named argument that is a Decidim::Organization" do
      let(:job_class) do
        tracker = state_tracker
        mod = described_class
        Class.new(Decidim::ApplicationJob) do
          include tracker
          include mod

          def perform(first, org, third, fourth); end
        end
      end
      let(:arguments) { ["first", organization, "third", "fourth"] }

      it_behaves_like "changed current URL options with host" do
        let(:expected_host) { organization.host }
      end

      context "when the argument value is not a Decidim::Organization" do
        let(:arguments) { ["first", "second", nil, "fourth"] }

        it_behaves_like "changed current URL options with host" do
          let(:expected_host) { "localhost" }
        end

        context "and default URL options do not define the host" do
          before { allow(Rails.env).to receive(:local?).and_return(false) }

          it_behaves_like "unchanged current URL options"
        end
      end
    end

    context "with an argument responding to #organization" do
      let(:job_class) do
        tracker = state_tracker
        mod = described_class
        Class.new(Decidim::ApplicationJob) do
          include tracker
          include mod

          def perform(first, second, third, fourth); end
        end
      end
      let(:arguments) { ["first", "second", record, "third"] }
      let(:record) do
        if organization.present?
          build(:user, organization:)
        else
          build(:user).tap do |user|
            user.organization = nil
          end
        end
      end

      it_behaves_like "changed current URL options with host" do
        let(:expected_host) { organization.host }
      end

      context "when the organization value is not a Decidim::Organization" do
        let(:organization) { nil }

        it_behaves_like "changed current URL options with host" do
          let(:expected_host) { "localhost" }
        end

        context "and default URL options do not define the host" do
          before { allow(Rails.env).to receive(:local?).and_return(false) }

          it_behaves_like "unchanged current URL options"
        end

        context "and another argument has a valid organization association" do
          let(:arguments) { ["first", record, "third", valid_record] }
          let(:valid_record) { build(:user) }

          it_behaves_like "changed current URL options with host" do
            let(:expected_host) { valid_record.organization.host }
          end
        end
      end
    end

    context "with unresolved organization" do
      let(:job_class) do
        tracker = state_tracker
        mod = described_class
        Class.new(Decidim::ApplicationJob) do
          include tracker
          include mod

          def perform; end
        end
      end
      let(:arguments) { [] }

      it_behaves_like "changed current URL options with host" do
        let(:expected_host) { "localhost" }
      end

      context "when default URL options do not define the host" do
        before { allow(Rails.env).to receive(:local?).and_return(false) }

        it_behaves_like "unchanged current URL options"
      end
    end
  end

  describe "#perform_now" do
    subject { job_target.perform_now(*arguments) }

    it_behaves_like "working job with assets"
  end

  describe "#perform_later" do
    subject { perform_enqueued_jobs(only: job_target) { job_target.perform_later(*arguments) } }

    before do
      organization&.save!

      if respond_to?(:record)
        # Insert without validations and callbacks
        record.class.insert(record.attributes.compact_blank) # rubocop:disable Rails/SkipsModelValidations
        record.id = record.class.order(:id).last.id
      end
      valid_record.save! if respond_to?(:valid_record)
    end

    it_behaves_like "working job with assets"
  end
end
