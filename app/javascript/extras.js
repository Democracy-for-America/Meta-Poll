// Get query parameters
window.getParameterByName = function(name, url) {
  if (!url) url = window.location.href;
  name = name.replace(/[\[\]]/g, '\\$&');
  var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
      results = regex.exec(url);
  if (!results) return null;
  if (!results[2]) return '';
  return decodeURIComponent(results[2].replace(/\+/g, ' '));
}

$(document).on('turbolinks:load', function() {
  // Social media buttons
  $('.social').click(function(){
    var width = window.innerWidth;
    var left = (width - 574)/2;
    return !window.open(this.href, '_blank', 'height=436, width=574, top=100, left=' + left);
  });

  // SMS Disclaimer dropdown
  window.showSmsIfCompletePhone = function(duration) {
    if ( $("#dragPhone").length > 0 && $("#dragPhone").val().replace(/[^0-9]/g,"").length >= 10 ) {
      if ( duration > 0 ) { $("#dragSmsOptIn").prop('checked', true); }
      $("#smsDisclaimer").slideDown(duration);
    }
  }

  $("#dragPhone").on('change keyup', function() { showSmsIfCompletePhone(500); });
  showSmsIfCompletePhone(0);

  $("input.write-in").on('change keyup', function() {
    $(this).closest('.draggable').find('.field-value.write-in-value').text( $(this).val() );
  })
});

// modal
window.hideModal = function() {
  $("#modal").animate({top: "100%"}, 500, function() {
    $("#modalContent iframe").remove();
    $("#modalVote").text("");
    $("#modalOffice").text("");
    $("#modalContent").html("");
    $("a.overlay").hide();
  });
  return true;
}