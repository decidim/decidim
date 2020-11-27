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

        attr_accessor :name
        attr_accessor :year
        attr_accessor :coverage
        attr_accessor :metadata

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
    end

    it_behaves_like "encrypted record"

    context "with a superclass responding to the attribute accessors" do
      let(:superklass) do
        mod = described_class
        Class.new do
          include mod

          attr_accessor :name
          attr_accessor :year
          attr_accessor :coverage
          attr_accessor :metadata

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
        expect(subject.name).to be(nil)
        expect(subject.year).to be(nil)
        expect(subject.coverage).to be(nil)
        expect(subject.metadata).to be(nil)
      end
    end
  end
end
