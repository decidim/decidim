# frozen_string_literal: true

require "spec_helper"

describe "decidim_initiatives:notify_progress", type: :task do
  let!(:vote) { create(:initiative_user_vote) }

  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  it "runs gracefully" do
    allow(vote).to receive(:encrypted_metadata).and_return("Tg51HMVBe6RYQoDadh1a38vU1r8QxeBUp+Fn3tuIAExyyZW9b1D+GgADAWjn6wq5nYqLst5t6m6sIuSor5ax0qB5NnK3S8/wYrjCB/JDoWEDTCZvPVxII26Y3yLRU4s2Hy8Tm6ihz6WZXWMdoSSQxZY4Y5phb0DME5JxBsLTNuGQyJzyIpGq7TtuAxlFITOqkUhT6K+zjl1dZ6DgLvTu+Lr8P8rXYgH7UQ==--nv6FyA29/uBUwHBr--+l8hshe6514c6mB4lpyeJw==")
    allow(Rails.application).to receive(:secret_key_base).and_return("d5619e9849ac5064733594e15f218525516dbae9f50d2a2f0c17937fac9f8ab16343c23147873f33c2afeba21a78948c8e68404d363217b6c59858cd3eae1953")

    expect { task.execute }.not_to raise_error

    vote.reload

    expect(vote.decrypted_metadata).to eq({ "name_and_surname" => "John Doe", "document_type" => "identification_number", "document_number" => "123456789X", "gender" => "man", "date_of_birth" => "1985-11-03", "postal_code" => "123456" })
  end

  it "runs gracefully when no encrypted data" do
    allow(vote).to receive(:encrypted_metadata).and_return(nil)
    allow(Rails.application).to receive(:secret_key_base).and_return("d5619e9849ac5064733594e15f218525516dbae9f50d2a2f0c17937fac9f8ab16343c23147873f33c2afeba21a78948c8e68404d363217b6c59858cd3eae1953")

    expect { task.execute }.not_to raise_error

    expect(vote.decrypted_metadata).to eq({})
  end

  it "raises error when encrypted data is invalid" do
    allow(vote).to receive(:encrypted_metadata).and_return("FOO BAR")
    allow(Rails.application).to receive(:secret_key_base).and_return("d5619e9849ac5064733594e15f218525516dbae9f50d2a2f0c17937fac9f8ab16343c23147873f33c2afeba21a78948c8e68404d363217b6c59858cd3eae1953")

    expect { task.execute }.not_to raise_error

    vote.reload

    expect { vote.decrypted_metadata }.to raise_error(ActiveSupport::MessageEncryptor::InvalidMessage)
  end
end
