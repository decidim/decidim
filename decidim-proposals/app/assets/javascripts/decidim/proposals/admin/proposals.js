// = require_self

var selectedProposalsCount = function(){
  return $("#js-recategorize-proposals-count").text($('.js-check-all-proposal:checked').length);
}

if($('#js-form-recategorize-proposals').length){
  $("#js-recategorize-proposals-actions").addClass('invisible');

  //select all checkboxes
  $(".js-check-all").change(function(){  //"select all" change
    $(".js-check-all-proposal").prop('checked', $(this).prop("checked")); //change all ".checkbox" checked status

    if($(this).prop("checked")){
      $("#js-recategorize-proposals-actions").removeClass('invisible');
    } else {
      $("#js-recategorize-proposals-actions").addClass('invisible');
    }

    selectedProposalsCount()
  });

  // proposal checkbox change
  $('.js-check-all-proposal').change(function(){
    //uncheck "select all", if one of the listed checkbox item is unchecked
    if(false == $(this).prop("checked")){ //if this item is unchecked
      $(".js-check-all").prop('checked', false); //change "select all" checked status to false
    }
    //check "select all" if all checkbox proposals are checked
    if ($('.js-check-all-proposal:checked').length == $('.js-check-all-proposal').length ){
      $(".js-check-all").prop('checked', true);
      $("#js-recategorize-proposals-actions").removeClass('invisible');
    }

    if($(this).prop("checked")){
      $("#js-recategorize-proposals-actions").removeClass('invisible');
    }

    if($('.js-check-all-proposal:checked').length == 0){
      $("#js-recategorize-proposals-actions").addClass('invisible');
    }

    selectedProposalsCount()
  });
}
