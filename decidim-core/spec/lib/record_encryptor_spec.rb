# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe RecordEncryptor do
    subject do
      instance = klass.new
      instance.name = name
      instance.year = year
      instance.coverage = coverage
      instance.metadata = metadata
      instance
    end

    let(:ae) { Decidim::AttributeEncryptor }

    let(:klass) do
      mod = described_class
      Class.new do
        include mod

        attr_accessor :name, :year, :coverage, :metadata

        encrypt_attribute :name, type: :string
        encrypt_attribute :year, type: :integer
        encrypt_attribute :coverage, type: :float
        encrypt_attribute :metadata, type: :hash
      end
    end

    let(:name) { "Decidim" }
    let(:year) { 2016 }
    let(:coverage) { 87.4 }
    let(:metadata) { { foo: "bar" } }

    shared_examples_for "encrypted record" do
      it "returns the unencrypted values for all accessors with correct types" do
        # If the stored instance values are note encrypted properly, the decrypt
        # calls would throw an ActiveSupport::MessageEncryptor::InvalidMessage.
        expect(subject.name).to eq(name)
        expect(ae.decrypt(subject.instance_variable_get(:@name))).to eq(name)
        expect(subject.name).to be_instance_of(String)
        expect(subject.year).to eq(year)
        expect(ae.decrypt(subject.instance_variable_get(:@year))).to eq(year)
        expect(subject.year).to be_instance_of(Integer)
        expect(subject.coverage).to eq(coverage)
        expect(ae.decrypt(subject.instance_variable_get(:@coverage))).to eq(coverage)
        expect(subject.coverage).to be_instance_of(Float)
        expect(subject.metadata).to eq(metadata)
        expect(
          ae.decrypt(subject.instance_variable_get(:@metadata)[:foo])
        ).to eq(ActiveSupport::JSON.encode(metadata[:foo]))
        expect(subject.metadata).to be_instance_of(Hash)
      end

      it "returns the original value when the value is not encrypted" do
        subject.instance_variable_set(:@name, "Unencrypted")

        # This would throw an ActiveSupport::MessageEncryptor::InvalidMessage
        # which happens if the decryption fails. This is catched and the
        # original value is returned instead.
        expect(subject.name).to eq("Unencrypted")
      end

      it "returns the original value when the decryption fails due to invalid signature" do
        # Test the decryption process in case the following is configured for
        # the application (could be the case for installations dating the
        # pre-Rails 5.2 era):
        # Rails.application.config.active_support.use_authenticated_message_encryption = false
        #
        # This is also true for all instances that have the following in their
        # `config/application.rb` (Defaults from pre-Rails 5.2):
        #   config.load_defaults 5.1
        allow(ActiveSupport::MessageEncryptor).to receive(:use_authenticated_message_encryption).and_return(false)

        subject.instance_variable_set(:@name, "Unencrypted")

        # This would throw an ActiveSupport::MessageVerifier::InvalidSignature
        # which happens if the decryption fails. This is catched and the
        # original value is returned instead.
        expect(subject.name).to eq("Unencrypted")
      end

      it "returns the original hash values when the JSON parsing fails for the hash values" do
        subject.instance_variable_set(
          :@metadata,
          "email" => "example001@example.org",
          "verification_code" => "123456789"
        )

        expect(subject.metadata).to eq(
          "email" => "example001@example.org",
          "verification_code" => 123_456_789
        )
      end

      it "returns the original hash values for deep hashes that cannot be passed to decryption" do
        deep_metadata = {
          "location" => {
            "Country" => {
              "Province" => {
                "Region" => {
                  "Sub-region" => {
                    "Municipality" => {
                      "Quarter" => {
                        "Block" => "Street"
                      }
                    }
                  }
                }
              }
            }
          },
          "foobar" => "",
          "extras" => {
            "foo" => {
              "bar" => "baz"
            }
          }
        }

        subject.instance_variable_set(
          :@metadata,
          deep_metadata
        )

        expect(subject.metadata).to eq(deep_metadata)
      end
    end

    it_behaves_like "encrypted record"

    context "with a superclass responding to the attribute accessors" do
      let(:superklass) do
        mod = described_class
        Class.new do
          include mod

          attr_accessor :name, :year, :coverage, :metadata

          def original_name
            @name
          end

          def original_year
            @year
          end

          def original_coverage
            @coverage
          end

          def original_metadata
            @metadata
          end
        end
      end

      let(:klass) do
        Class.new(superklass) do
          encrypt_attribute :name, type: :string
          encrypt_attribute :year, type: :integer
          encrypt_attribute :coverage, type: :float
          encrypt_attribute :metadata, type: :hash
        end
      end

      it_behaves_like "encrypted record"

      it "encrypts the original values" do
        # If the values are note encrypted properly, the decrypt calls would
        # throw an ActiveSupport::MessageEncryptor::InvalidMessage.
        expect(ae.decrypt(subject.original_name)).to eq(name)
        expect(ae.decrypt(subject.original_year)).to eq(year)
        expect(ae.decrypt(subject.original_coverage)).to eq(coverage)
        expect(ae.decrypt(subject.original_metadata[:foo])).to eq(
          ActiveSupport::JSON.encode(metadata[:foo])
        )
      end
    end

    context "without a superclass and without an instance variable" do
      subject { klass.new }

      let(:klass) do
        mod = described_class
        Class.new do
          include mod

          encrypt_attribute :name, type: :string
          encrypt_attribute :year, type: :integer
          encrypt_attribute :coverage, type: :float
          encrypt_attribute :metadata, type: :hash
        end
      end

      it "returns nil for all getters" do
        expect(subject.name).to be_nil
        expect(subject.year).to be_nil
        expect(subject.coverage).to be_nil
        expect(subject.metadata).to be_nil
      end
    end

    context "with active record" do
      subject do
        klass.create!(
          title:,
          reference:
        )
      end

      let(:klass) do
        mod = described_class
        Class.new(ApplicationRecord) do
          include mod

          self.table_name = "decidim_dummy_resources_dummy_resources"

          encrypt_attribute :title, type: :hash
          encrypt_attribute :reference, type: :string
        end
      end

      let(:title) { { en: "Test title" } }
      let(:reference) { "REF123" }

      it "returns the unencrypted values for all accessors with correct types" do
        # If the stored instance values are note encrypted properly, the decrypt
        # calls would throw an ActiveSupport::MessageEncryptor::InvalidMessage.
        expect(subject.title).to eq("en" => title[:en])
        expect(
          ae.decrypt(subject.read_attribute(:title)["en"])
        ).to eq(ActiveSupport::JSON.encode(title[:en]))
        expect(subject.title).to be_instance_of(Hash)
        expect(subject.reference).to eq(reference)
        expect(ae.decrypt(subject.read_attribute(:reference))).to eq(reference)
        expect(subject.reference).to be_instance_of(String)
      end

      context "when changing JSON attribute values directly" do
        before do
          subject.title[:en] = "Updated title"
          subject.save!
        end

        it "stores the updated value in the database after save" do
          resource = klass.find(subject.id)
          expect(resource.title["en"]).to eq("Updated title")
        end
      end

      context "when updating an encrypted attribute without storing the value" do
        before do
          subject.reference # this should cache the original decrypted value
          subject.reference = "UPDREF"
        end

        it "updates the cached variable correctly" do
          expect(subject.reference).to eq("UPDREF")
        end
      end
    end
  end
end
