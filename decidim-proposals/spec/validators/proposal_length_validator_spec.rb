# frozen_string_literal: true

require "spec_helper"

describe ProposalLengthValidator do
  subject { validatable.new(body:) }

  let(:validatable) do
    Class.new do
      def self.model_name
        ActiveModel::Name.new(self, nil, "Validatable")
      end

      include Decidim::AttributeObject::Model
      include ActiveModel::Validations

      attribute :body

      validates :body, proposal_length: {
        minimum: 15,
        maximum: ->(_record) { 100 }
      }
    end
  end

  context "when the text is too short" do
    let(:body) { "Lorem ipsum d" }

    it { is_expected.to be_invalid }
  end

  context "when the text is too long" do
    let(:body) { "a" * 101 }

    it { is_expected.to be_invalid }
  end

  context "when the text is written in HTML" do
    let(:body) do
      data = File.read(Decidim::Dev.asset("avatar.jpg"))
      encoded = Base64.encode64(data)

      <<~HTML
        <p>Text before the image.</p>
        <p><img src="data:image/png;base64,#{encoded.strip}"></p>
        <p>Some other text after the image.</p>
      HTML
    end

    it { is_expected.to be_valid }
  end
end
