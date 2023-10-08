# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentSecurityPolicy do
    subject { described_class.new(organization, additional_content_security_policies) }
    let!(:organization) { create(:organization, content_security_policy: additional_content_security_policies) }

    let(:additional_content_security_policies) { {} }

    describe "output_policy" do
      it { is_expected.to respond_to(:output_policy) }
      it { expect(subject.output_policy).to be_a(String) }
      it { expect(subject.output_policy).to include("default-src 'self' 'unsafe-inline'; ") }
      it { expect(subject.output_policy).to include("script-src 'self' 'unsafe-inline' 'unsafe-eval';") }
      it { expect(subject.output_policy).to include("style-src 'self' 'unsafe-inline';") }
      it { expect(subject.output_policy).to include("img-src 'self' *.hereapi.com data:;") }
      it { expect(subject.output_policy).to include("connect-src 'self' *.hereapi.com *.jsdelivr.net data:;") }
      it { expect(subject.output_policy).to include("font-src 'self';") }
      it { expect(subject.output_policy).to include("frame-src 'self' www.youtube-nocookie.com player.vimeo.com;") }
      it { expect(subject.output_policy).to include("media-src 'self'") }
    end

    describe "append_csp_directive" do
      it { is_expected.to respond_to(:append_csp_directive) }
      it { expect(subject.append_csp_directive("default-src", "https://example.org")).to be_a(Array) }
      it { expect(subject.append_csp_directive("default-src", "https://example.org")).to include("https://example.org") }

      context "when policies as passed as hash" do
        let(:additional_content_security_policies) { { "img-src": %w('self') } } # rubocop:disable Lint/PercentStringArray

        it "does not raise any errors" do
          expect { subject.output_policy }.not_to raise_error(RuntimeError)
        end
      end

      context "when policies as passed as string" do
        let(:additional_content_security_policies) { { "img-src" => %w('self') } } # rubocop:disable Lint/PercentStringArray

        it "does not raise any errors" do
          expect { subject.output_policy }.not_to raise_error(RuntimeError)
        end
      end

      context "when append to existing directives" do
        before do
          subject.append_csp_directive("default-src", "https://example.org")
        end

        it { expect(subject.output_policy).to include("default-src 'self' 'unsafe-inline' https://example.org;") }
      end

      context "when adding new supported rules" do
        before do
          subject.append_csp_directive("object-src", "https://example.org")
        end

        it { expect(subject.output_policy).to include("object-src https://example.org") }
      end

      it "when has invalid rule" do
        expect { subject.append_csp_directive("invalid-rule", "https://example.org") }.to raise_error(RuntimeError)
      end
    end
  end
end
