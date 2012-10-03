$(document).ready(function() {
   $('#sort_by_ordered').hide();

   $('.sort_by').click(function() {
      $(this).attr("disabled", "disabled");
      $('#sort_by_ordered').show();

      var val = $('#sort_by_ordered').val();
      if (val != "") {
         $('#sort_by_ordered').val(val + ", " + $(this).val());
      } else {
         $('#sort_by_ordered').val($(this).val());
      }
   });

   $('#sort_reset').click(function() {
      $('.sort_by').removeAttr("disabled").prop("checked", false);
      $('#sort_by_ordered').hide().val('');
   });
});
