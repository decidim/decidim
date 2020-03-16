$(() => {
  $(".data_picker-modal-content").on("change keyup", "#proposals_filter", (event) => {
    const filter = event.target.value.toUpperCase()

    $("#proposals_list li").each((index, li) => {
      $(li).toggle(li.textContent.toUpperCase().indexOf(filter) > -1)
    })
  })
})
