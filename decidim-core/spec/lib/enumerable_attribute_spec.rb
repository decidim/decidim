# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe EnumerableAttribute do
    let(:template_klass) do
      Class.new(Decidim::DummyResources::DummyResource) do
        include Decidim::EnumerableAttribute
      end
    end
    let(:model) { klass.new }

    describe "#enum_fields" do
      let(:klass) do
        Class.new(template_klass) do
          enum_fields :state, %w(foo bar)
        end
      end

      describe "scopes" do
        it { expect(klass).to respond_to(:foo) }
        it { expect(klass).to respond_to(:bar) }
        it { expect(klass).to respond_to(:not_foo) }
        it { expect(klass).to respond_to(:not_bar) }
      end

      describe "methods" do
        it { expect(model).to respond_to(:foo?) }
        it { expect(model).to respond_to(:bar?) }
      end
    end

    describe "#enum_fields, enable_scopes:" do
      let(:klass) do
        Class.new(template_klass) do
          enum_fields :state, %w(foo bar), enable_scopes: false
        end
      end

      describe "scopes" do
        it { expect(klass).not_to respond_to(:foo) }
        it { expect(klass).not_to respond_to(:bar) }
        it { expect(klass).not_to respond_to(:not_foo) }
        it { expect(klass).not_to respond_to(:not_bar) }
      end
    end

    describe "#enum_fields , method_suffix:" do
      let(:klass) do
        Class.new(template_klass) do
          enum_fields :state, %w(foo bar), method_suffix: :fizz
        end
      end

      describe "methods" do
        it { expect(model).to respond_to(:foo_fizz?) }
        it { expect(model).to respond_to(:bar_fizz?) }
        it { expect(model).not_to respond_to(:foo?) }
        it { expect(model).not_to respond_to(:bar?) }
      end
    end

    describe "#enum_fields , prepend_scope:" do
      let(:klass) do
        Class.new(template_klass) do
          scope :alpha, -> { where("(1 = 2 or 1 = 1)") }
          scope :beta, -> { where("(3 = 2 or 1 = 1)") }
          enum_fields :state, %w(foo bar), prepend_scope: [:alpha, :beta]
        end
      end

      describe "scopes" do
        it { expect(klass.foo.to_sql).to include("(1 = 2 or 1 = 1)") }
        it { expect(klass.foo.to_sql).to include("(3 = 2 or 1 = 1)") }
        it { expect(klass.bar.to_sql).to include("(1 = 2 or 1 = 1)") }
        it { expect(klass.bar.to_sql).to include("(3 = 2 or 1 = 1)") }
      end
    end
  end
end
