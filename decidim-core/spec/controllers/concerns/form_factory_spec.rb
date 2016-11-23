require "spec_helper"

module Decidim
  describe FormFactory do
    let(:form_klass) { Class.new }
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

    subject { producer.form(form_klass) }

    describe "instance" do
      it "returns an instance of the form" do
        expect(subject.instance).to be_kind_of(form_klass)
      end
    end

    describe "from_params" do
      let(:params) { { foo: "bar" } }
      let(:default_context) do
        {
          current_organization: "organization",
          current_user: "user"
        }
      end

      it "initializes the form using the params" do
        expect(form_klass).to receive(:from_params).with(params, anything)

        subject.from_params(params)
      end

      it "injects the current user and current organization" do
        expect(form_klass).to receive(:from_params).with(params, default_context)
        subject.from_params(params)
      end

      context "with custom context" do
        let(:context) { { somthing: "baz" } }

        it "initializes the form with params and the context" do
          expect(form_klass).to receive(:from_params).with(params, hash_including(context))
          subject.from_params(params, context)
        end
      end
    end

    describe "from_model" do
      let(:attributes) do
        {
          id: 1,
          name: "Joe"
        }
      end

      let(:model) do
        double(attributes: attributes)
      end

      it "initializes the form with the model's attributes" do
        expect(form_klass).to receive(:from_params).with(attributes, anything)
        subject.from_model(model)
      end

      context "with custom context" do
        let(:context) { { somthing: "baz" } }

        it "initializes the form with params and the context" do
          expect(form_klass).to receive(:from_params).with(attributes, hash_including(context))
          subject.from_model(model, context)
        end
      end
    end
  end
end
