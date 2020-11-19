# frozen_string_literal: true

require "spec_helper"

describe "decidim_elections:generate_identification_keys", type: :task do
  it "runs gracefully" do
    expect { task.execute }.not_to raise_error
  end

  context "with the task output" do
    before { task.execute }

    it "includes the private key" do
      check_message_printed("PRIVATE KEY")
      check_message_printed('{"kty":"RSA","n":"')
    end

    it "includes the public key" do
      check_message_printed("PUBLIC KEY")
      check_message_printed("kty=RSA&n=")
    end

    it "includes a reference to the documentation guide" do
      check_message_printed("docs/services/bulletin_board.md")
    end
  end
end
