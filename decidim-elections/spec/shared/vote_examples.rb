# frozen_string_literal: true

shared_context "with elections router" do
  let(:router) { Decidim::EngineRouter.main_proxy(component).decidim_participatory_process_elections }
end

shared_examples "doesn't allow to vote" do
  include_context "with elections router"

  it "doesn't allow clicking in the vote button" do
    visit router.election_path(id: election.id)

    expect(page).not_to have_link("Vote")
  end

  it "doesn't allow to access directly to the vote page" do
    visit router.new_election_vote_path(election_id: election.id)

    expect(page).to have_content("You are not allowed to vote on this election at this moment.")
  end
end

shared_examples "allows to vote" do
  before do
    visit_component

    click_link translated(election.title)
    click_link "Start voting"
  end

  it_behaves_like "uses the voting booth"

  it "doesn't show the preview alert" do
    expect(page).not_to have_content("This is a preview of the voting booth.")
  end
end

shared_examples "allows to change the vote" do
  before do
    visit_component

    click_link translated(election.title)

    expect(page).to have_content("You have already voted in this election.")
    click_link "Change your vote"
  end

  it_behaves_like "uses the voting booth"

  it "doesn't show the preview alert" do
    expect(page).not_to have_content("This is a preview of the voting booth.")
  end
end

shared_examples "allows to preview booth" do
  include_context "with elections router"

  before do
    visit router.election_path(id: election.id)

    click_link "Preview"
  end

  it_behaves_like "uses the voting booth"

  it "shows the preview alert" do
    expect(page).to have_content("This is a preview of the voting booth.")
  end
end

shared_examples "uses the voting booth" do
  include_context "with elections router"
  include_context "when mocking the bulletin board in the browser"

  before do
    proxy.stub("http://bulletin-board.lvh.me:8000/api", method: "post").and_return(
      headers: { "Access-Control-Allow-Origin" => "*" },
      json: {
        data: {
          pendingMessage: {
            status: "accepted",
            __typename: "PendingMessage"
          },
          election: {
            logEntries: [
              {
                messageId: "decidim-test-authority.10002.create_election+a.decidim-test-authority",
                signedData: "eyJhbGciOiJSUzI1NiJ9.eyJpYXQiOjE2MTIyNzAyNjUsIm1lc3NhZ2VfaWQiOiJkZWNpZGltLXRlc3QtYXV0aG9yaXR5LjEwMDAyLmNyZWF0ZV9lbGVjdGlvbithLmRlY2lkaW0tdGVzdC1hdXRob3JpdHkiLCJzY2hlbWUiOnsibmFtZSI6ImR1bW15IiwicGFyYW1ldGVycyI6eyJxdW9ydW0iOjJ9fSwidHJ1c3RlZXMiOlt7Im5hbWUiOiJEZWNpZGltIFRlc3QgVHJ1c3RlZSAxIiwicHVibGljX2tleSI6IntcImt0eVwiOlwiUlNBXCIsXCJuXCI6XCIwVGRiSzNDNzlBTWVfU25PNUlpYlRKQlVGcm90VE1IRUk0WU9IX0w1VkhIcDU5a08yQ1pTRWdIOVpFbml2T2dVT3o2Vy12X0JhdVZJYS1aTHpRdWlIaDZnZEE5ajBwTjV6RWtQSFlKcU9JcE1MMEpjblRFenlZRW01X29MQmlfbVdJUGdLTWE1bkltVlN3cHdnOXZmNTUySk9femtqM3QzRnp4c0oxVFV5N3NabkFYekxkenpHcWdUdlRGZnFRV3VJdGJOclZOOHZrM1NYMDFrd3gtZG51MUFva1RNcm5XR2lvMEhoYnpZOVpaTUJtVXhsZUd0Y053dWJKSGk0MmszOTJMaUowUlZyQXh2ZHlCM1dWSnhYWEw3VHE4ZGkwWUVQbnViTFlZREpHeVEwMHFzR0pfVXdJMEgwb3l4U252ZHdZUW9IRWxSSGZZUnNlRExvLVhFYnVJaFctaF9KNnN3V2RZQjhNZHB4MTJzb0VFU1Z1QkQ0ZXAzUFVKekNoRmQtLWJPVUJDQ054T2FRU1kycDRwWjdaZjJiRVRTZWQwZVJNTEhmd1BSWnd4RkZoN0ZkSXFxMFV6Ul85OWp3akRvRG5lRnVPWXd3emVjOHQxMlJiSW1YY0hzaTJHUGJMemxDekRBSWtJeWRrVXN3X0o4M2ZWWGJQRldSODZycHpXY0MwN3VILUhYUG9VbjBEaUktMFR3ZmZBcmVEYnVtU2FaVXpKUkx1Sm5KQVBFZ19YRTFkNndwSHVZd3BUQTVzNXJYRWlvTFlkb2d2alUzMFg3cXIxaTdfLWFMY2kyak85RmRKR2RZRlRmZURxYlVFd0FweG9FY1NjajNKNUd3SmRWSmV0bWVXNzR2SVpRa0htNkx3QWNRdFJJeVRHUmgzMnpzd05NdjRqRC10Y1wiLFwiZVwiOlwiQVFBQlwiLFwia2lkXCI6XCIxMWI3NWE3NzQxNDM0OGZlNjkyZWU5YTk4Yjg5NmMyNTBlOTkyZWU4NjM3MjZjMjcxNzY5MTNiODA2Y2NlYmYyXCJ9In0seyJuYW1lIjoiRGVjaWRpbSBUZXN0IFRydXN0ZWUgMiIsInB1YmxpY19rZXkiOiJ7XCJrdHlcIjpcIlJTQVwiLFwiblwiOlwic1UyTW5ONU8wQVRKdWExZUxYNlZ5Nm1yUnBjZXZmcXFhaFdGMk0yLXVUZ0VKSnh6YjF3ZFEwM085bGIwWTNzRzhITE1pZDl6Tkt4Rk4zZnFRdGtqbTExNEhfSzVCYXh0SlRIbW80cUNueXgwRktWdjBtNTJQZG5ub21vM3B2WmFCZXRidDhZWWptQy1Mc09aVVhvdEJJVVEzQng1SW9rU0pMVDh0cE1WdXZUZjlmMFMySExON0U3M3JIVHZ4LUVnc1JlbGF6aktCblNaVFZfbFJiYVM3U3R4T1JfUVFBbHppMU90UlEyMU5uMkpPam40Zy1PM2VDUjNST20xbGlFMHpGZUZjNmk4NzJ6TFJXTVcxTVMyLTV6dGNSbmgwY0xVQmhZU3NlTE9fcWtNOFNYNE1YYTdmdngySXF1TFRLai01cW5tVWNNanlHVmJNR1hHU2taSkp1WXd1YnFtVGZiSTk4UGl4TC1Tcmo1cXN2S1J5RmVXTjBNUE5BODM5ZFhReXhwQ3FCRDJmT3RyZm1mWnZZclZnVmRQZXNDUnExWGtyTlJaU3oxcFI2N1pqSG16WUpsbE1kR1gzQlpGZ2RaSVJYdk1jRl9VZ01ydDVRZXJtX2V6ZUhxVVpSTndkRlMzUVFraEYxRnluU3FkMkFFVXVMejhKR0huT3dFRkR2ajFzUm4wYXNidTZpT2hlODVQUDZGcHhaZ3pTRVo5QjI2UFozY0NmVmFYbFpLblMwMFZ6MVlPaDhIczlnUTJTWnhicTZDdUw2ZklJOUtObnB2amx4bzVEYWVscXpUVTRuTldzOWxSR3hIY2VGVGR6R0pFZ29VYUV2X3ktcy1IeHluRDlfelFKTi1oaUVFNnNucTk5UlBnbGlyamwtdmVhWEJWZnJkUTZKVXJJUThcIixcImVcIjpcIkFRQUJcIixcImtpZFwiOlwiZjVmMmUzZDgxNjEyZWE2Y2U0N2I5MDEzZjRjZjgwNDUzNmFkNzM2ZmViYWY2MmJlYTNmNTUxYjdhY2FiMzRiMFwifSJ9LHsibmFtZSI6IkRlY2lkaW0gVGVzdCBUcnVzdGVlIDMiLCJwdWJsaWNfa2V5Ijoie1wia3R5XCI6XCJSU0FcIixcIm5cIjpcInlTSlNXRzdQLW5zTjIwZ2F2X040elNxN2J6U1hJRlJhd29ZdHhkZnZhNzgyUW1aLVBFYlRaRTBFcmUzMXI5T0hnTnhrU3BaakFBTjRZVEV2dUFBN0FzMmE2S3JSdU5GaHUwQWlCVGs1M2RtcWZFZE0yUHpRN1lNT1VQRlFpeVBlUVo5MVE1SkcwSmx5OWIzd21HczYzbG03aUdVN3A2R3B0Nl9hdXJiQ2YwUC1uckRRNGZMcEpEWVBXZndnNWkwQ0dkMjl1d3pPVFhqRDFGVF96S3laaThtWEpqanZNRTNGelJlUWUyX1pfeWJQOGFjMi1iTVQ4d0phbnEyemVYYnBUVFlsM2RrVlFSYm1jbjdXU1NrNHVZc0dfai0wX1NHanZIZ0JER2lLV2tqbUIzNW1Vd0hSVmh3NW8yY3pueWpNSkg3TnN6VTdSRmJ0NWxETXF4aFpvcG0ydW9XTXQxSHJWQ094T2FtaWhLaV9adjlOekpGZGNIbkNKanNhakM4NS1UWDFFb3pvUTNzUEFFMWFRaERyOVBvYno2T2JvWTJZV0swV2xoZG94Y0J1ZHNmT2l6bVJlWWVtVXVMQW5sa1RJaGU4NmVsMGJIUEhxY0UzbHRWZHcwVTdFd2dpeVBabVlzWEpGWDh5UmRQOFdCOTJjTktQbC15blZ5czN0a21OZHZKUGwyckw0Si16dlBtS0lsZm5NZUpRRGJuOEwxSHBJOXBmVTN0Z1d3MDBxNkk4blBaMG1uaU95S1MtWnphRHVXNzV4ZTNCdXNzdVctMUwyLUhyR3VZajgzUDNhX3NEVVNQLV9zZG8zVEMxSk92VjNYYU8xc3dPVGtoWl9JQ2k1Zk5oV1JBUnV2a0o4Y21XbFN0ejVSRnRVc2h2OGdpWkNUSDBmWVNXZHdrXCIsXCJlXCI6XCJBUUFCXCIsXCJraWRcIjpcIjg4MzQwM2I1YWRiOWUzNTA0OGY1M2VhYThkOTUyOGQ5ZjExZDdiMzM1NjBkOGFlYjlkMTFlNDA4OTJiMDAzMTJcIn0ifV0sImRlc2NyaXB0aW9uIjp7Im5hbWUiOnsidGV4dCI6W3sidmFsdWUiOiJBbGwgdGhlIHdvcmxkICdzIGEgc3RhZ2UsIGFuZCBhbGwgdGhlIG1lbiBhbmQgd29tZW4gbWVyZWx5IHBsYXllcnMuIFRoZXkgaGF2ZSB0aGVpciBleGl0cyBhbmQgdGhlaXIgZW50cmFuY2VzOyBBbmQgb25lIG1hbiBpbiBoaXMgdGltZSBwbGF5cyBtYW55IHBhcnRzLiIsImxhbmd1YWdlIjoiZW4ifV19LCJzdGFydF9kYXRlIjoiMjAyMS0wMi0wOVQxMjo1MTowNVoiLCJlbmRfZGF0ZSI6IjIwMjEtMDItMTZUMTI6NTE6MDVaIiwiY2FuZGlkYXRlcyI6W3siYmFsbG90X25hbWUiOnsidGV4dCI6W3sidmFsdWUiOiJDYW4gb25lIGRlc2lyZSB0b28gbXVjaCBvZiBhIGdvb2QgdGhpbmc_LiIsImxhbmd1YWdlIjoiZW4ifV19LCJvYmplY3RfaWQiOiJjYW5kaWRhdGUtOSJ9LHsiYmFsbG90X25hbWUiOnsidGV4dCI6W3sidmFsdWUiOiJJIGxpa2UgdGhpcyBwbGFjZSBhbmQgd2lsbGluZ2x5IGNvdWxkIHdhc3RlIG15IHRpbWUgaW4gaXQuIiwibGFuZ3VhZ2UiOiJlbiJ9XX0sIm9iamVjdF9pZCI6ImNhbmRpZGF0ZS0xMCJ9LHsiYmFsbG90X25hbWUiOnsidGV4dCI6W3sidmFsdWUiOiJUcnVlIGlzIGl0IHRoYXQgd2UgaGF2ZSBzZWVuIGJldHRlciBkYXlzLiIsImxhbmd1YWdlIjoiZW4ifV19LCJvYmplY3RfaWQiOiJjYW5kaWRhdGUtMTEifSx7ImJhbGxvdF9uYW1lIjp7InRleHQiOlt7InZhbHVlIjoiQmxvdywgYmxvdywgdGhvdSB3aW50ZXIgd2luZCEgVGhvdSBhcnQgbm90IHNvIHVua2luZCBhcyBtYW4ncyBpbmdyYXRpdHVkZS4iLCJsYW5ndWFnZSI6ImVuIn1dfSwib2JqZWN0X2lkIjoiY2FuZGlkYXRlLTEyIn1dLCJjb250ZXN0cyI6W3sidHlwZSI6IlJlZmVyZW5kdW1Db250ZXN0Iiwic2VxdWVuY2Vfb3JkZXIiOjAsInZvdGVfdmFyaWF0aW9uIjoib25lX29mX20iLCJuYW1lIjoiQWxsIHRoZSB3b3JsZCAncyBhIHN0YWdlLCBhbmQgYWxsIHRoZSBtZW4gYW5kIHdvbWVuIG1lcmVseSBwbGF5ZXJzLiBUaGV5IGhhdmUgdGhlaXIgZXhpdHMgYW5kIHRoZWlyIGVudHJhbmNlczsgQW5kIG9uZSBtYW4gaW4gaGlzIHRpbWUgcGxheXMgbWFueSBwYXJ0cy4iLCJudW1iZXJfZWxlY3RlZCI6MSwibWluaW11bV9lbGVjdGVkIjoxLCJiYWxsb3RfdGl0bGUiOnsidGV4dCI6W3sidmFsdWUiOiJBbGwgdGhlIHdvcmxkICdzIGEgc3RhZ2UsIGFuZCBhbGwgdGhlIG1lbiBhbmQgd29tZW4gbWVyZWx5IHBsYXllcnMuIFRoZXkgaGF2ZSB0aGVpciBleGl0cyBhbmQgdGhlaXIgZW50cmFuY2VzOyBBbmQgb25lIG1hbiBpbiBoaXMgdGltZSBwbGF5cyBtYW55IHBhcnRzLiIsImxhbmd1YWdlIjoiZW4ifV19LCJiYWxsb3Rfc3VidGl0bGUiOnsidGV4dCI6W3sidmFsdWUiOiJCbG93LCBibG93LCB0aG91IHdpbnRlciB3aW5kISBUaG91IGFydCBub3Qgc28gdW5raW5kIGFzIG1hbidzIGluZ3JhdGl0dWRlLiIsImxhbmd1YWdlIjoiZW4ifV19LCJiYWxsb3Rfc2VsZWN0aW9ucyI6W3sic2VxdWVuY2Vfb3JkZXIiOjAsImNhbmRpZGF0ZV9pZCI6ImNhbmRpZGF0ZS05Iiwib2JqZWN0X2lkIjoiY29udGVzdC01LXNlbGVjdGlvbi05In0seyJzZXF1ZW5jZV9vcmRlciI6MSwiY2FuZGlkYXRlX2lkIjoiY2FuZGlkYXRlLTEwIiwib2JqZWN0X2lkIjoiY29udGVzdC01LXNlbGVjdGlvbi0xMCJ9XSwib2JqZWN0X2lkIjoiY29udGVzdC01In0seyJ0eXBlIjoiUmVmZXJlbmR1bUNvbnRlc3QiLCJzZXF1ZW5jZV9vcmRlciI6MSwidm90ZV92YXJpYXRpb24iOiJvbmVfb2ZfbSIsIm5hbWUiOiJDYW4gb25lIGRlc2lyZSB0b28gbXVjaCBvZiBhIGdvb2QgdGhpbmc_LiIsIm51bWJlcl9lbGVjdGVkIjoxLCJtaW5pbXVtX2VsZWN0ZWQiOjEsImJhbGxvdF90aXRsZSI6eyJ0ZXh0IjpbeyJ2YWx1ZSI6IkNhbiBvbmUgZGVzaXJlIHRvbyBtdWNoIG9mIGEgZ29vZCB0aGluZz8uIiwibGFuZ3VhZ2UiOiJlbiJ9XX0sImJhbGxvdF9zdWJ0aXRsZSI6eyJ0ZXh0IjpbeyJ2YWx1ZSI6IkJsb3csIGJsb3csIHRob3Ugd2ludGVyIHdpbmQhIFRob3UgYXJ0IG5vdCBzbyB1bmtpbmQgYXMgbWFuJ3MgaW5ncmF0aXR1ZGUuIiwibGFuZ3VhZ2UiOiJlbiJ9XX0sImJhbGxvdF9zZWxlY3Rpb25zIjpbeyJzZXF1ZW5jZV9vcmRlciI6MCwiY2FuZGlkYXRlX2lkIjoiY2FuZGlkYXRlLTExIiwib2JqZWN0X2lkIjoiY29udGVzdC02LXNlbGVjdGlvbi0xMSJ9LHsic2VxdWVuY2Vfb3JkZXIiOjEsImNhbmRpZGF0ZV9pZCI6ImNhbmRpZGF0ZS0xMiIsIm9iamVjdF9pZCI6ImNvbnRlc3QtNi1zZWxlY3Rpb24tMTIifV0sIm9iamVjdF9pZCI6ImNvbnRlc3QtNiJ9XX19.NioypK8zybFgr-lyejSVkkgG21YerKeS3K9KRG2Sz2HWf7OSyjTy6SI7C2qY9S7I85k2viBGKkn1taVY67ENikw2raIm-qPEQZ-RN2lYCQ4FAdYZSgmKR_bTxvdZnJYMCJBzgmLswIsncQQEVIxhNQIKvGR3Y6xFmMtAHVvMgUKnFZ0GfdscsfX2tXjCHKTRnXQNSdOCJ8YQO3KO-qi_G-F_-EqOYbm00cOGVW7yFYnZM3JXAJ8cf3zr__6mFNxc8TCsoadt-LKFaBAc_2aAhx2RA6hHlOwsEPtFndBcKthizr8D5d0m6XEHvziAL7p91zkPH0CCLj6gkaWqZnrD7NznSsceWuXnUFioD12y1S6E7jKU6ctb7geMf9gtuCH2B7eusooMDf2tpe0nNXnL0iFcafjOPy2c5tfWQ1vgzGbn5MHZB5qrAhsMb2qhAwAhYwPytTKhTSplH4XQTjgF6RTD_bnahKdD8Mxv1_IqwRXnRFT-kpylxT-iJlF-hXqVjwH_iiXnCV01dPCLKxFX4PglEdLEVbSoVysruQ8FFtWzhgmR5Mtl6lJQgYRfvoD1ue_TIvhJzFZ6RKw96vNgMHyx5DsnGeaOKZYUE9JiZsXI5_aGfb99pDyINw0DYVFNqFrIABz32JIWcIP32gUbm_j04koeoUUPINMicnVrnWQ",
                contentHash: nil,
                __typename: "LogEntry"
              },
              {
                messageId: "decidim-test-authority.10002.end_key_ceremony+b.bulletin-board",
                signedData: "eyJhbGciOiJSUzI1NiJ9.eyJpYXQiOjE2MTIyNzAyNjUsIm1lc3NhZ2VfaWQiOiJkZWNpZGltLXRlc3QtYXV0aG9yaXR5LjEwMDAyLmVuZF9rZXlfY2VyZW1vbnkrYi5idWxsZXRpbi1ib2FyZCIsImNvbnRlbnQiOiJ7XCJqb2ludF9lbGVjdGlvbl9rZXlcIjo0OTE5MzcyN30ifQ.lVBjl0kA38dUHpEayahBZPBJ8uh1Q6t4Fx-nxNGzN-Azjd2rJd75JyAbcRO3vVCdhx-PIqt54G9zOaulUqP-gD70iK8xYxq0GHVn31ty03m1PFhZo9mEHevEBneDoxI3ir_i1qfGjrDqesJTMlMzSujd_X-LCDXAa26-ZlbJoHv8EB1-YTLznDpUiyTWJgcjKpdmXpUgSShrd_mxS13KgI-3naqvKjc_FELM5Ma_KK2t77a5evT0h2POHvqPHMULp2sYS2auCLmQCZ64liUwFec6yLiHzJlHjyMC2rk8bgx5CxgcWWcZMZK7OPIuMGgdCf11UVAYQnCKjcphs6RoUMckVDO-tq4V5-XwOs6FIqoVHuII5uVOSK-WlgzaLdMH8DLiSPtNKUzq4Og_8M-fsBBqHH2DVI4_BVlCB9zx9ZxOevaNU6TXyi2CffIHIfFaRBTI-016Year4TQfxMzkUX_cz-wZbpcnci3NHm-HFAxzyCZNmSiY4co4Vj2QUaxwz30PScX-Xw2OQZp5LgkcWuy1rdNgWqqri6h0MVRxwXzMWzR1_G4JT5ba2IEEtarCWVcqd4g5KK2-ec9WlUQLFl1RBuDfhFiI722xv3v4Zl95EacASMT7_icTYi-n4EK-ZqDP020SyBcYJYitt_oQCF0MvAG0QvgH_jt_tzRIL3c",
                contentHash: "f434c97048bca9bbd052e55a3216727ca32f0ffbdadcb401f004a3e5e588ac20",
                __typename: "LogEntry"
              }
            ],
            __typename: "Election"
          },
          logEntry: {
            messageId: "decidim-test-authority.10002.vote.cast+v.2b4ed424cb13184168b02ff54e0fc1d00ca666548007e5309c95faa92fe4e0f4",
            signedData: "eyJhbGciOiJSUzI1NiJ9.eyJjb250ZW50Ijoie1wiYmFsbG90X3N0eWxlXCI6XCJ1bmlxdWVcIixcInF1ZXN0aW9uXzg2MVwiOltcIjU4MDhcIl0sXCJxdWVzdGlvbl84NjNcIjpbXCI1ODI0XCIsXCI1ODIxXCIsXCI1ODE5XCJdLFwicXVlc3Rpb25fODYyXCI6W1wiNTgxOFwiLFwiNTgxNVwiLFwiNTgxN1wiLFwiNTgxNFwiLFwiNTgxMlwiXX0iLCJpYXQiOjE2MTA1Njc4NDQsIm1lc3NhZ2VfaWQiOiJkZWNpZGltLXRlc3QtYXV0aG9yaXR5LjEwMDAyLnZvdGUuY2FzdCt2LjJiNGVkNDI0Y2IxMzE4NDE2OGIwMmZmNTRlMGZjMWQwMGNhNjY2NTQ4MDA3ZTUzMDljOTVmYWE5MmZlNGUwZjQifQ.eSnPvE3_Ty6IkTX-DFRGkH1tfBzpuFlqdgPo2EVz8laCznNN_xb_EwbMPHAtH0hrB0vT5slrPaM1HczUxylbrOIOwvziisccGe4Ey-mOaM56w8SicIJJjmx6E6f1LeRukoTkzvO2Qmn2U13Majzx0LPkkVTwIJw9rkgvIDfVre0l0qUn_yRlV2opJslmLPpjtBTZ-xvi35qu_J5C2GJzVAvb31CMgZUAKMLx75wyfqy2O0Els6C-jItMCR0xStfkNnI5QS5IkgA4L-rNLkOBEEuq2R4UJ4qiPHr2ZiFIUxP_g-Xd7fwRxQfzgt0dgxEVZYPE2DvtsAmaSEOT0VMymkjjsZzp7CtQf5dYEdXrpN4BRAf64gQ13MPh6NOnrLWlYNqlR7KhmxK4lr0LgosFdbD6xhXN8n37lNHz-u2CWs2XJgIDpEe9TOSlCj0GPpjV4jwRCrPUOtfx8_fUaxs2NhPrMTZGgshA7v_W4SGFZWb3ughPXV8XF5tauDnLTB2Ln-GKO9A4mQ-Wh1OXfUsdv_wLidtIOotzf62oujAHCJQHtlhMNsU-dLDpLlyxeHoaBY16j2pM46ufle7nCOMxg3TSZtfAuGoIjiAf9lRXyHRf5MLFPLVitO2-zV3xS4xPRL7WC7YvvpAGHK5Opq4xG_cnXht38VJrBIAuIbWL1hU",
            contentHash: "128997c75969f759069b42c14c21e577d57e61f8314ab041847bfa994a28f483",
            __typename: "LogEntry"
          }
        }
      }
    )
  end

  it "uses the voting booth", :vcr, :billy, :slow do
    selected_answers = []
    non_selected_answers = []

    # shows a yes/no/abstention question: radio buttons, no random order, no extra information
    question_step(1) do |question|
      expect_not_valid

      select_answers(question, 1, selected_answers, non_selected_answers)
    end

    # shows a projects question: checkboxes, 6 maximum selections, random order with extra information
    question_step(2) do |question|
      select_answers(question, 3, selected_answers, non_selected_answers)

      expect_valid

      check(translated(non_selected_answers.last.title), allow_label_click: true)

      expect_not_valid

      uncheck(translated(non_selected_answers.last.title), allow_label_click: true)
    end

    # shows a candidates question: checkboxes, random order without extra information
    question_step(3) do |question|
      select_answers(question, 5, selected_answers, non_selected_answers)
    end

    # shows a nota question: checkboxes, random order without extra information, nota checked
    question_step(4) do |_question|
      check(I18n.t("decidim.elections.votes.new.nota_option"), allow_label_click: true)

      expect(page).to have_selector("label.is-disabled").exactly(8).times

      expect_valid
    end

    # confirm step
    non_question_step("#step-4") do
      expect(page).to have_content("CONFIRM YOUR VOTE")

      selected_answers.each { |answer| expect(page).to have_i18n_content(answer.title) }
      non_selected_answers.each { |answer| expect(page).not_to have_i18n_content(answer.title) }

      within "#edit-step-2" do
        click_link("edit")
      end
    end

    # edit step 2
    question_step(2) do |question|
      change_answer(question, selected_answers, non_selected_answers)
    end

    question_step(3)

    question_step(4)

    # confirm step
    non_question_step("#step-4") do
      expect(page).to have_content("CONFIRM YOUR VOTE")

      selected_answers.each { |answer| expect(page).to have_i18n_content(answer.title) }
      non_selected_answers.each { |answer| expect(page).not_to have_i18n_content(answer.title) }

      click_link("Confirm")
    end

    # encrpyting vote page
    non_question_step("#encrypting") do
      expect(page).to have_content("Encoding vote...")
    end

    # confirmed vote page
    non_question_step("#confirmed_page") do
      expect(page).to have_content("Vote confirmed")
      expect(page).to have_content("Your vote has already been cast!")
    end

    # close voting booth without alert
    page.find("a.focus__exit").click

    expect(page).to have_current_path router.election_path(id: election.id)
  end

  def question_step(number)
    expect_only_one_step
    within "#step-#{number - 1}" do
      question = election.questions[number - 1]
      expect(page).to have_content("QUESTION #{number} OF 4")
      expect(page).to have_i18n_content(question.title)

      yield question if block_given?

      click_link("Next")
    end
  end

  def non_question_step(id)
    expect_only_one_step
    within id do
      yield
    end
  end

  def select_answers(question, number, selected, non_selected)
    answers = question.answers.to_a
    number.times do
      answer = answers.delete(answers.sample)
      selected << answer
      if number == 1
        choose(translated(answer.title), allow_label_click: true)
      else
        check(translated(answer.title), allow_label_click: true)
      end
    end
    non_selected.concat answers
  end

  def change_answer(question, selected, non_selected)
    new_answer = question.answers.select { |answer| non_selected.member?(answer) }.first
    old_answer = question.answers.select { |answer| selected.member?(answer) }.first

    selected.delete(old_answer)
    uncheck(translated(old_answer.title), allow_label_click: true)
    non_selected << old_answer

    non_selected.delete(new_answer)
    check(translated(new_answer.title), allow_label_click: true)
    selected << new_answer
  end

  def expect_only_one_step
    expect(page).to have_selector(".focus__step", count: 1)
  end

  def expect_not_valid
    expect(page).not_to have_link("Next")
  end

  def expect_valid
    expect(page).to have_link("Next")
  end
end
