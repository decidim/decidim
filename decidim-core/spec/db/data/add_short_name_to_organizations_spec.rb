# frozen_string_literal: true

require "spec_helper"
require "./db/data/20251125144141_add_short_name_to_organizations"

describe AddShortNameToOrganizations do
  let(:migrator) do
    described_class.new.tap do |m|
      m.verbose = false
    end
  end

  describe "#up" do
    shared_examples_for "adds the short name" do |describe_title, example_title, name_hash, short_name_hash|
      describe describe_title do
        let!(:organization) do
          org = create(:organization, name: name_hash)
          org.update_column(:short_name, {}) # rubocop:disable Rails/SkipsModelValidations
          org
        end

        it example_title do
          expect(organization.reload.short_name).to eq({})
          migrator.migrate(:up)
          expect(organization.reload.short_name).to eq(short_name_hash)
        end
      end
    end

    it_behaves_like "adds the short name",
                    "with a normal name",
                    "generates short_name from name",
                    { en: "MyOrganization" },
                    { "en" => "MyOrganizati" }

    it_behaves_like "adds the short name",
                    "with a name containing spaces",
                    "removes spaces and generates short_name",
                    { en: "My Organization" },
                    { "en" => "MyOrganizati" }

    it_behaves_like "adds the short name",
                    "with a short name without spaces",
                    "uses the name as short_name",
                    { en: "Test" },
                    { "en" => "Test" }

    it_behaves_like "adds the short name",
                    "with a name that results in less than 3 characters",
                    "does not set short_name",
                    { en: "A B" },
                    {}

    it_behaves_like "adds the short name",
                    "with a long name",
                    "truncates to 12 characters",
                    { en: "Very Long Organization Name" },
                    { "en" => "VeryLongOrga" }

    it_behaves_like "adds the short name",
                    "with a blank name",
                    "does not set short_name",
                    { en: "" },
                    {}

    it_behaves_like "adds the short name",
                    "with a Spanish name",
                    "generates short_name from Spanish name",
                    { es: "MiOrganización", en: "MyOrganization" },
                    { "es" => "MiOrganizaci", "en" => "MyOrganizati" }

    it_behaves_like "adds the short name",
                    "with a French name containing accents",
                    "removes spaces and generates short_name from French",
                    { fr: "Mon Organisation", en: "My Organization" },
                    { "fr" => "MonOrganisat", "en" => "MyOrganizati" }

    it_behaves_like "adds the short name",
                    "with a Catalan name",
                    "generates short_name from Catalan name",
                    { ca: "LaMevaOrganització", en: "MyOrganization" },
                    { "ca" => "LaMevaOrgani", "en" => "MyOrganizati" }

    it_behaves_like "adds the short name",
                    "with multiple locales and spaces",
                    "generates short_name for all locales",
                    { en: "My Organization", es: "Mi Organización", ca: "La Meva Organització" },
                    { "en" => "MyOrganizati", "es" => "MiOrganizaci", "ca" => "LaMevaOrgani" }

    it_behaves_like "adds the short name",
                    "with German name",
                    "generates short_name from German name",
                    { de: "Meine Organisation", en: "My Organization" },
                    { "de" => "MeineOrganis", "en" => "MyOrganizati" }

    it_behaves_like "adds the short name",
                    "with faker multilingual organization",
                    "generates short_name for all valid locales",
                    {
                      "ar" => "سعيد شركة",
                      "bg" => "Schultz-Mosciski",
                      "ca" => "Garau, Miquel and Pitart",
                      "cs" => "Rogahn, Farrell and Spinka",
                      "da" => "DuBuque, Gislason and Buckridge",
                      "de" => "Oeser KG",
                      "el" => "Wunsch, Adams and Simonis",
                      "en" => "Emmerich Inc",
                      "eo" => "Gusikowski Inc",
                      "es" => "Fonseca, Robles y Rivera Asociados",
                      "et" => "McClure, Leffler and Zboncak",
                      "eu" => "Corwin and Sons",
                      "fa" => "ندوشن Group",
                      "fi" => "Zemlak, Swift and Lemke",
                      "fr" => "Duval EURL",
                      "ga" => "Rippin Group",
                      "gl" => "Jacobson, Schinner and Feil",
                      "hr" => "Hamill Group",
                      "hu" => "Lueilwitz-Schaden",
                      "id" => "Haryanto, Waluyo and Idris",
                      "is" => "Romaguera and Sons",
                      "it" => "Amato, Negri e Barone SPA",
                      "ja" => "加藤運輸株式会社",
                      "ko" => "한국 민준",
                      "lb" => "Mante-Emard",
                      "lt" => "Pfeffer, Nienow and Schaefer",
                      "lv" => "Irbe AS",
                      "mt" => "Ebert, Zulauf and Grady",
                      "nl" => "Tegelaar V.O.F.",
                      "no" => "Bartell-Corwin",
                      "pl" => "Matusiak-Flis",
                      "pt" => "Moreira-Araújo",
                      "ro" => "Kautzer and Sons",
                      "ru" => "ИП Эдуард",
                      "sk" => "Labudová s.r.o.",
                      "sl" => "Sanford-Leannon",
                      "sr" => "Jakubowski, Ullrich and Reynolds",
                      "sv" => "Andersson Group",
                      "tr" => "Özkanlı, Zengel and Davut",
                      "uk" => "ФОП Яцьків",
                      "vi" => "Cửa hàng Triệu",
                      "es-MX" => "Rivas y Lozano S.R.L",
                      "es-PY" => "Ceballos S.A.",
                      "fi-pl" => "Leannon-Stroman",
                      "fr-CA" => "Aubért et Rémy",
                      "pt-BR" => "Marcondes, Ferraço e Solimões",
                      "zh-CN" => "杜-雷",
                      "machine_translations" => { "zh-TW" => "章 Inc" }
                    },
                    {
                      "ar" => "سعيدشركة",
                      "bg" => "Schultz-Mosc",
                      "ca" => "Garau,Miquel",
                      "cs" => "Rogahn,Farre",
                      "da" => "DuBuque,Gisl",
                      "de" => "OeserKG",
                      "el" => "Wunsch,Adams",
                      "en" => "EmmerichInc",
                      "eo" => "GusikowskiIn",
                      "es" => "Fonseca,Robl",
                      "et" => "McClure,Leff",
                      "eu" => "CorwinandSon",
                      "fa" => "ندوشنGroup",
                      "fi" => "Zemlak,Swift",
                      "fr" => "DuvalEURL",
                      "ga" => "RippinGroup",
                      "gl" => "Jacobson,Sch",
                      "hr" => "HamillGroup",
                      "hu" => "Lueilwitz-Sc",
                      "id" => "Haryanto,Wal",
                      "is" => "Romagueraand",
                      "it" => "Amato,Negrie",
                      "ja" => "加藤運輸株式会社",
                      "ko" => "한국민준",
                      "lb" => "Mante-Emard",
                      "lt" => "Pfeffer,Nien",
                      "lv" => "IrbeAS",
                      "mt" => "Ebert,Zulauf",
                      "nl" => "TegelaarV.O.",
                      "no" => "Bartell-Corw",
                      "pl" => "Matusiak-Fli",
                      "pt" => "Moreira-Araú",
                      "ro" => "KautzerandSo",
                      "ru" => "ИПЭдуард",
                      "sk" => "Labudovás.r.",
                      "sl" => "Sanford-Lean",
                      "sr" => "Jakubowski,U",
                      "sv" => "AnderssonGro",
                      "tr" => "Özkanlı,Zeng",
                      "uk" => "ФОПЯцьків",
                      "vi" => "CửahàngTriệu",
                      "es-MX" => "RivasyLozano",
                      "es-PY" => "CeballosS.A.",
                      "fi-pl" => "Leannon-Stro",
                      "fr-CA" => "AubértetRémy",
                      "pt-BR" => "Marcondes,Fe",
                      "zh-CN" => "杜-雷"
                    }
  end

  describe "#down" do
    it "raises IrreversibleMigration exception" do
      expect { migrator.migrate(:down) }.to raise_error(ActiveRecord::IrreversibleMigration)
    end
  end
end
