# frozen_string_literal: true

require "spec_helper"
require "decidim/elections/jwk_utils"

module Decidim
  module Elections
    describe BulletinBoardClient do
      subject { described_class.new(params) }

      let(:params) do
        {
          identification_private_key: identification_private_key,
          server: server,
          api_key: api_key,
          scheme: scheme,
          authority_name: authority_name
        }
      end

      let(:identification_private_key) do
        { "kty": "RSA", "n": "pNgMt8lnPDD3TlWYGhRiV1oZkPQmnLdiUzwyb_-35qKD9k-HU86xo0uSgoOUWkBtnvFscq8zNDPAGAlZVokaN_z9ksZblSce0LEl8lJa3ICgghg7e8vg_7Lz5dyHSQ3PCLgenyFGcL401aglDde1Xo4ujdz33Lklc4U9zoyoLUI2_viYmNOU6n5Mn0sJd30FeICMrLD2gX46pGe3MGug6groT9EvpKcdOoJHKoO5yGSVaeY5-Bo3gngvlgjlS2mfwjCtF4NYwIQSd2al-p4BKnuYAVKRSgr8rYnnjhWfJ4GsCaqiyXNi5NPYRV6gl_cx_1jUcA1rRJqQR32I8c8QbAXm5qNO4URcdaKys9tNcVgXBL1FsSdbrLVVFWen1tfWNfHm-8BjiWCWD79-uk5gI0SjC9tWvTzVvswWXI5weNqqVXqpDydr46AsHE2sG40HRCR3UF3LupT-HwXTcYcOZr5dJClJIsU3Hrvy4wLssub69YSNR1Jxn-KX2vUc06xY8CNIuSMpfufEq5cZopL6O2l1pRsW1FQnF3s078_Y9MaQ1gPyBo0IipLBVUj5IjEIfPuiEk4jxkiUYDeqzf7bAvSFckp94yLkRWTs_pEZs7b_ogwRG6WMHjtcaNYe4CufhIm9ekkKDeAWOPRTHfKNmohRBh09XuvSjqrx5Z7rqb8", "e": "AQAB", "kid": "b8dba1459df956d60107690c34fa490db681eac4f73ffaf6e4055728c02ddc8e", "d": "Uh3KIBe1VJez6pLbBUrYPlmE2N-3CGSWF46qNX62lq6ofB_b8xTJCuaPonJ3iYoE0aPEeVDrefq5m3-0wFXl-LQPgXlMj_1_7UgB9jeuSZ_N1WDK6P2EJPx5YS09O1gkpVxK7Mx_sZQe77wmUUH-eI7tg__qfUrB7E0Yn_cTpBATI2qlYaQsz6-A7e1MVvixq_ilmzVAZvuBrPp5mCZVb6FlXrV_PU9-UPIrD3O1La1lfO6SPBSbSGQkmGHwD2QbkHn9D_R_Vs-z_0TkM_dX71jIPQhrle3pN222KuJ8eQqwr9QP6biQMBuT5eKgr3MVtfUDRpp4sCEq9GIFwSd8LvbmGPrOoz8ueOEQ05nisIBQuOTYiWpYs2CEV062HR1bLFRLDUcSlflGNr0bgiXTUFx4wxRG06OaI-rQ6nG3M8TE0I0phMNCG3c7YyV28z_k2I65oQF9aKtiwFwc0YsUSGPTOFZGWHuCCPLm0lFeebpI_JIYqIv70NJxbSZEBY8DAIqZPqP6y_CRo2_C7piCgsjg9pnF8cp45vz4L6DWZ0Tumc_5aRuqIBkYXXwP9TjqhzxL-2SQHIqUAjj6Y6S35tZT6ekZSbnPIKX_e42y6bDT_Ztf01QfKiTkcx3_I8RwOuh6CzJzr72AykQpU3XKOKF1x1GBtYyrno4jG5LgaGE", "p": "1UARZ-rRnpKG5NHKlXTys3irCy-d91edHL3fEIzDKvhMRQCIWh7dt8l0_sIpcBF-EbVilbFKj7yfgZBTr8EkAXHgweayK8rnlMqi2jte1_u-5DBtrGVVUTSQltSLDOZHK5QfUxVK6Bbk8K5ROLvef91oNgnSNWNOeoCZdlS55nMZcAgY_6mxSuuMq54Tgy8o4Ip890-ZEYY6OSFXhU-ieoGO4Jw--c6QzmCa3gGo2oVClidMNaM1jquK4Pj6xaoxR2NWeIX9Ix7k1P2B24pegyHXjSIpQ6JYdn352VViXi2tx7TTJh6ClNVjgoRmL4Gfy_IJNx0GhF5OB3yughUc7w", "q": "xePJGBt466qM9F0BPxWFjyWbIs_GNXr-lBGASui0Z94cfgFbsZwqRsWQEf7jDVQsDNVnPSWZ_Wd6UqoQaIxc0tE8gaokPG6A4EUDyoLaZ231ZydDVoWof8FnPDaJwrcPwZ4R6ZLKGmkfytCZuU9I_9B4uuV0dyjEzKfS-Os3UcLumKPlgJ71OZAb49GTqUHuTePcSJjyYOYXx6eE7i_1m8TjU9Ut18BJNQhLqWmerA6X1ijbR2_syY6GXhGSfciSBH8xVkiUnqXb2jt1bE8nwWw-Sam5ikjzNbXqqs978IcCE5HTddQmy99bwuArA8PLqIFj3OOO1CSo8oyn2XDgMQ", "dp": "Diky_rOZN-6DBq7nxQT_GOvqb9O5qbMnu8DgDzlJvJDAf9SJOXLTRmEaY9CA7_A5bvOcmFQtn13nObNb20_4FCB7zGSFcGMI_dh2-Ab5RV5yTrTok4onID1dXKbAlRq1ny825U2Eq-TZTyJEQoA3RkZtpSkBzInLrFbd2f3GWodKKSZggpnCLDd4H-1fXlbDYCXSJpoikAdZ1nFgXnnrUDdKRaAajnwpIYtIvXVewSQYR-BULzunUtIRZt8hx_6FRzhRha9gH_TtPTeYZ_vISuz0Y2rhUpx1Q2kaLlR9M8PUxm47l0xvX3LMKN6h6oWxFtn7wq0qwZ-Bjv24mOrOAQ", "dq": "nXGD10hURrwk9W7hxP0sjB2Rdnr06iv3THs4JWFL16_h32bZO1BSWoho_chbgYlMmtFXGFFIWVLxAcAI2gWC_MA4cbmapvIMW2LNh1vgxJW5v95_NuGUlECeEEwcAu1-_b7z5XBCmAy3nLem9sbb_5wv0hMpPH0VRvbnZeBO3SBIkO0lddYCqU-8wN9HqkyoexQleSUnAm1O0iy4GIHT2aEmdNaRaKy2EhmNiTZdZeseZueOvyGPtTVONp2ofacMdcN0z39jr22qo9DWtdusd7nVPOpqkllEF6GrGUeHBnGD92n4YjDuxRnqefu8fXxUFrcLav0p8CNSv9ek291woQ", "qi": "w6hfKEBLLHRWPkjajgxZyyetj-UFfVkILRT0plOllJ2JV8whcOXRXbiXH2r8zqMeyMFrrMwmuvv4TVQaruKB0ZQOG7Tz5Lw0RZEREOLnBwc3vSi_iLd-jBz01LdExTpqsAHMkaMQR9x62J8DE1ZNxVdn3ELYKik0f1L2r_WErzhvT1uq69HAybUp6WHcFYH0PSqHg4LOneXAdU1_g-ji2Zn9dlA_2oYGQ5S6JXPV7v2IVbEFpxyVD1lPbFT0iKhyZZevictjgD_JGHveIVqsq5w0Csyz08h0oEW9hYEq-4bquMxSf18gjldoS5uQPD7FUECgL8bxsCdc4hP6UEKYGw" }
      end

      let(:server) { "https://bb.example.org" }
      let(:api_key) { Random.urlsafe_base64(30) }
      let(:scheme) do
        {
          name: "test",
          parameters: {
            quorum: 2
          }
        }
      end
      let(:authority_name) { "Decidim Test Authority" }
      let(:election_data) do
        {
          schema: scheme,
          election_id: authority_name
        }
      end

      let(:identification_private_key_content) do
        Decidim::Elections::JwkUtils.import_private_key(identification_private_key)
      end

      it { is_expected.to be_configured }

      it "has an identification public key" do
        expect(subject.public_key).not_to be_nil
      end

      context "when private key is not present" do
        let(:identification_private_key) { "" }

        it { is_expected.not_to be_configured }

        it "doesn't have an identification public key" do
          expect(subject.public_key).to be_nil
        end
      end

      context "when server is not present" do
        let(:server) { "" }

        it { is_expected.not_to be_configured }
      end

      context "when api_key is not present" do
        let(:api_key) { "" }

        it { is_expected.not_to be_configured }
      end

      context "when election data is called" do
        it "encodes election data" do
          expect(subject.encode_data(election_data)).to eq(
            "eyJhbGciOiJSUzI1NiJ9.eyJzY2hlbWEiOnsibmFtZSI6InRlc3QiLCJwYXJhbWV0ZXJzIjp7InF1b3J1bSI6Mn19LCJlbGVjdGlvbl9pZCI6IkRlY2lkaW0gVGVzdCBBdXRob3JpdHkifQ.LdFMOzHHFdpTRr7IZsktM9HxucKhfJ8cCjbyVTQu4deyiQPTczeqNAqOIUvgBFmrRGZ5qRvN8dS0sfmdW0I2J3079ooTavVwd6t-A6MuJzRUzuGx1M7jGwrnmUyQ5_r3e7dtpGdqKqCoEydmP3LaXS6G4dZTftk_MAvQQlbRCUg9VBcedlNI6OUZW-vATK4aEfJlMjZEBgzzw-7Oh3FR1mqE8FqKrTCH2Ro9jwwS2sc0moq5tPG368IR86JwRmBlNO7bq5nD-ZSpGF8hlcphucZGSbm95GBrkWjZxCsEPThj8pEBng-e_Duz-8ctVFDGbocjc90-ksLkhhHAwnPg82zlC3jp2CpQjBvs870kkKR8-qAwW3J_YMjWHsfrXb0LpSSEYNnZolks1F0ZsjxNmn5cPbB2g5ItSFGv53OGyEc5iq8g-7tkkuVfGxKt4kTP3WsULuV1ClkjswZiTVOQPSRAuDyWpWogT6fCe6r0wtzs3z3nz5p7aO48VBo18hRwmmLap49dzATDDCuFw8T182_BAm99JaJ7SebAyEBiNHCqU2FtMQUL_YeXrNeuC586w-oA_LFz0kRVyxaB3ZUkzcry96vWJoYTvvoI_3zU3n_o0xCiiKzxRAatGW6thagEkbRC3AQlGuwqECxCSNf3cv7JD8MWsKLZNHWAHxlDYpc"
          )
        end
      end
    end
  end
end
