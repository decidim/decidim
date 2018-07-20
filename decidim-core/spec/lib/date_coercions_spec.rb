# frozen_string_literal: true

require "spec_helper"

describe Decidim do
  let(:date) { Date.current }

  before do
    TmpFormWithDate = Class.new(Rectify::Form) do
      attribute :test_date, Date
    end
  end

  after { Object.send :remove_const, :TmpFormWithDate }

  it "correctly coerces available locales" do
    I18n.available_locales.each do |locale|
      I18n.with_locale(locale) do
        form = TmpFormWithDate.from_params(test_date: date.strftime(I18n.t("date.formats.datepicker")))
        expect(form.test_date).to eq(date)
      end
    end
  end

  it "correctly coerces custom formats" do
    I18n.available_locales += ["fake_locale"]

    I18n.backend.store_translations(:fake_locale, date: { formats: { datepicker: "%d :> %m () %Y !!" } })
    I18n.with_locale(:fake_locale) do
      form = TmpFormWithDate.from_params(test_date: "#{date.day} :> #{date.month} () #{date.year} !!")
      expect(form.test_date).to eq(date)
    end
  end
end
