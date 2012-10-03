$(document).ready(function() {
   $('#sort_div').hide();

   $('.sort_by').click(function() {
      $(this).attr("disabled", "disabled");
      $('#sort_div').show();

      var val = $('#sort_by_ordered').val();
      if (val != "") {
         $('#sort_by_ordered').val(val + ", " + $(this).val());
      } else {
         $('#sort_by_ordered').val($(this).val());
      }
   });

   $('#sort_reset').click(function() {
      $('.sort_by').removeAttr("disabled").prop("checked", false);
      $('#sort_div').hide();
      $('sort_by_ordered').val('');
   });
});
