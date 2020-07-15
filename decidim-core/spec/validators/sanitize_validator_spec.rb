# frozen_string_literal: true

require "spec_helper"

describe SanitizeValidator do
  let(:validatable) do
    Class.new do
      def self.model_name
        ActiveModel::Name.new(self, nil, "Validatable")
      end

      include Virtus.model
      include ActiveModel::Validations

      attribute :body

      validates :body, sanitize: true
    end
  end

  let(:subject) { validatable.new(body: body) }

  context "when body is reasonable" do
    [
      %(I am a very reasonable body, ain't I? I have the right length, the right style, the right words. Yup.),
      %("Validate bodies", they said. "It's gonna be fun!", they said.),
      %(I contain special characters because I'm à la mode.)
    ].each do |a_body|
      describe "like \"#{a_body}\"" do
        let(:body) { a_body }

        it "validates first character" do
          expect(subject).to be_valid
        end
      end
    end
  end

  context "when text begins by invalid char" do
    %w(= + - @).each do |char|
      let(:body) { char + Faker::Lorem.sentence }

      it "like '#{char}' char" do
        expect(subject).to be_invalid
      end
    end
  end
end
