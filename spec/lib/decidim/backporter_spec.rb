# frozen_string_literal: true

require "decidim/backporter"

describe Decidim::Backporter do
  subject { described_class.new(token:, pull_request_id:, version_number:, exit_with_unstaged_changes:) }

  let(:token) { "1234" }
  let(:pull_request_id) { 123 }
  let(:version_number) { "0.1" }
  let(:exit_with_unstaged_changes) { true }

  describe ".backport_branch" do
    let(:pull_request_title) { "Hello world" }

    it "works as expected" do
      expect(subject.send(:backport_branch, pull_request_title)).to eq "backport/0.1/hello-world-123"
    end

    context "when the title has a backtick" do
      let(:pull_request_title) { "Hello world `free -m`" }

      it "escapes it" do
        expect(subject.send(:backport_branch, pull_request_title)).to eq "backport/0.1/hello-world-free--m-123"
      end
    end

    context "when the title has a dollar sign" do
      let(:pull_request_title) { "Hello world $(free -m)" }

      it "escapes it" do
        expect(subject.send(:backport_branch, pull_request_title)).to eq "backport/0.1/hello-world-free--m-123"
      end
    end

    # @see https://unix.stackexchange.com/a/270979
    context "when the title has a character that needs to be escaped" do
      let(:pull_request_title) { %q(Hello world `~!$&*(){[|\;'"↩<>?) }

      it "escapes it" do
        expect(subject.send(:backport_branch, pull_request_title)).to eq "backport/0.1/hello-world--123"
      end
    end
  end
end
