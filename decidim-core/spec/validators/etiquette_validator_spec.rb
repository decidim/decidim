# coding: utf-8
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

      attribute :title

      validates :title, etiquette: true
    end
  end

  let(:subject) { validatable.new(title: title) }

  context "when the title is reasonable" do
    [
      %(I am a very reasonable title, ain't I? I have the right length, the right style, the right words. Yup.),
      %("Validate titles", they said. "It's gonna be fun!", they said.),
      %(I contain special characters because I'm à la mode.)
    ].each do |a_title|
      describe "like \"#{a_title}\"" do
        let(:title) { a_title }

        it "validates too much caps" do
          expect(subject).to be_valid
        end
      end
    end
  end

  context "when the text has too much caps" do
    let(:title) { "A SCREAMING PIECE of text" }
    it { is_expected.to be_invalid }
  end

  context "when the text has too many marks" do
    let(:title) { "I am screaming!!?" }
    it { is_expected.to be_invalid }
  end

  context "when the text has very long words" do
    let(:title) { "This word is veeeeeeeeeeeeeeeeeeeeeeeeeeeeery long." }
    it { is_expected.to be_invalid }
  end

  context "when the text is written starting in downcase" do
    let(:title) { "i no care about grammer" }
    it { is_expected.to be_invalid }
  end

  context "when the title is too short" do
    let(:title) { "Oh my god" }
    it { is_expected.to be_invalid }
  end
end
