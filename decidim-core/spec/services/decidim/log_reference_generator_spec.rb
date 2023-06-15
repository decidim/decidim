# frozen_string_literal: true

require "spec_helper"

describe Decidim::LogReferenceGenerator do
  let(:generator) { described_class.new(request) }

  let(:request) do
    ActionDispatch::Request.new(request_env).tap do |request|
      request.request_method = "GET"
      request.request_id = SecureRandom.uuid
    end
  end
  let(:request_env) { {} }
  let(:organization) { create(:organization) }

  before do
    allow(Rails.application.config).to receive(:log_tags).and_return([->(request) { "dummy changes-#{request.request_id}" }, :request_id, "normal_string"])
  end

  describe "#generate_reference" do
    subject { generator.generate_reference }

    it { is_expected.to eq("[dummy changes-#{request.request_id}] [#{request.request_id}] [normal_string] ") }
  end
end
