# frozen_string_literal: true

require "spec_helper"

describe Decidim::Consultations::ConsultationsController, type: :controller do
  it "does not raise error to call current_participatory_space" do
    expect { controller.send(:current_participatory_space) }.not_to raise_error
  end
end
