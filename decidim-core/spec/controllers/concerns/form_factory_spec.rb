# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe FormFactory do
    subject { producer.form(form_klass) }

    let(:form_klass) do
      Class.new(Decidim::Form) do
        include ActiveModel::Naming

        def self.name
          "FooForm"
        end

        attribute :bar, String
      end
    end

    let(:producer) do
      Class.new do
        include Decidim::FormFactory

        def current_organization
          "organization"
        end

        def current_user
          "user"
        end
      end.new
    end

    describe "instance" do
      it "returns an instance of the form" do
        expect(subject.instance).to be_kind_of(form_klass)
      end
    end

    describe "from_params" do
      let(:params) { { bar: "baz" } }

      it "injects the params into the form" do
        form = subject.from_params(params)
        expect(form.bar).to eq("baz")
        expect(form.current_organization).to eq("organization")
        expect(form.current_user).to eq("user")
      end

      context "with custom context" do
        let(:context) { { something: "baz" } }

        it "initializes the form with params and the context" do
          form = subject.from_params(params, context)

          expect(form.bar).to eq("baz")
          expect(form.current_organization).to eq("organization")
          expect(form.current_user).to eq("user")
          expect(form.context.something).to eq("baz")
        end
      end
    end

    describe "from_model" do
      let(:attributes) do
        {
          bar: "baz"
        }
      end

      let(:model) do
        double(attributes)
      end

      it "initializes the form with the model's attributes" do
        form = subject.from_model(model)
        expect(form.bar).to eq("baz")
      end

      context "with custom context" do
        let(:context) { { something: "baz" } }

        it "initializes the form with params and the context" do
          form = subject.from_model(model, context)
          expect(form.context.something).to eq("baz")
          expect(form.current_organization).to eq("organization")
        end
      end
    end
  end
end
