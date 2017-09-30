# frozen_string_literal: true

require "spec_helper"

describe EtiquetteValidator do
  let(:validatable) do
    Class.new do
      def self.model_name
        ActiveModel::Name.new(self, nil, "Validatable")
      end

      include Virtus.model
      include ActiveModel::Validations

      attribute :body

      validates :body, etiquette: true
    end
  end

  let(:subject) { validatable.new(body: body) }

  context "when the body is reasonable" do
    [
      %(I am a very reasonable body, ain't I? I have the right length, the right style, the right words. Yup.),
      %("Validate bodies", they said. "It's gonna be fun!", they said.),
      %(I contain special characters because I'm à la mode.)
    ].each do |a_body|
      describe "like \"#{a_body}\"" do
        let(:body) { a_body }

        it "validates too much caps" do
          expect(subject).to be_valid
        end
      end
    end
  end

  context "when the text has too much caps" do
    let(:body) { "A SCREAMING PIECE of text" }

    it { is_expected.to be_invalid }
  end

  context "when the text has too many marks" do
    let(:body) { "I am screaming!!?" }

    it { is_expected.to be_invalid }
  end

  context "when the text has very long words" do
    let(:body) { "This word is veeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeery long." }

    it { is_expected.to be_invalid }
  end

  context "when the text is written starting in downcase" do
    let(:body) { "i no care about grammer" }

    it { is_expected.to be_invalid }
  end

  context "when the body is too short" do
    let(:body) { "Oh my god" }

    it { is_expected.to be_invalid }
  end
end
