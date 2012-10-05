$(document).ready(function() {
   resetForm(); 

   $('#add_course').click(function() {
      $('#course_div').append($('#course_copy').clone().removeAttr("id").show());
   });

   $('#add_force').click(function() {
      $('#force_div').append($('#force_copy').clone().removeAttr("id").show());
      fuckIE();
   });

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
      resetSortDiv();
   });

   $('#reset').click(function() {
      resetForm();
   });

   $('#generate').click(function() {
      generateTimetables();
   });

   fuckIE();
});

function resetForm() {
   hideSpinner();
   resetSortDiv();

   $('#input_form input[type="text"]').each(function() {
      $(this).val('');
   });

   $('#results').html('');
   fuckIE();
}

function resetSortDiv() {
   $('.sort_by').removeAttr("disabled").prop("checked", false);
   $('#sort_div').hide();
   $('#sort_by_ordered').val('');
}

function showSpinner() {
   $('#spinner_div').show();
}

function hideSpinner() {
   $('#spinner_div').hide();
}

function generateTimetables() {
   $('#results').html('');
   showSpinner();

   var courses = [];
   var force_courses = [];
   var force_course_times = [];

   $('.course').each(function(index, val) {
      courses.push($(val).val());
   });
   courses = courses.join(",");

   $('.force_course').each(function(index, val) {
      force_courses.push($(val).val());
   });
   force_courses = force_courses.join(",");

   $('.force_course_time').each(function(index, val) {
      force_course_times.push($(val).val());
   });
   force_course_times = force_course_times.join(",");

   $.ajax({
      url: "generate.json",
      type: "POST",

      data: {
         courses: courses,
         clash: $('#clash').val(),
         sort_by_ordered: $('#sort_by_ordered').val(),
         force_courses: force_courses,
         force_course_times: force_course_times
      },

      success: function(results) {
         hideSpinner();

         if (results.timetables.length > 0) {
            $('#results').html('<p>' + results.timetables.length.toString() + 
                                       ' timetable(s) generated.</p>');
         } else {
            $('#results').html('<p>No valid timetables found.</p>');
         }

         var htmlTables = "";
         for (var i = 0; i < results.timetables.length; i++) {
            htmlTables += timetableToHtml(results.courses, results.timetables[i]);
         }

         $('#results').html($('#results').html() + htmlTables);
         $("html, body").animate({scrollTop: $('#results').offset().top}, 900);
      },

      dataType: "json"
   });
}

function fuckIE() {
   if (!Modernizr.input.placeholder){
      $('input[type="text"]').each(function() {
         var placeholder = $(this).attr("placeholder");
         if (typeof(placeholder) != 'undefined' && placeholder != "") {
            $(this).val($(this).attr("placeholder"));
            $(this).css('color', '#999999');

            $(this).blur(function() {
               if ($(this).val() == "") {
                  $(this).val($(this).attr("placeholder"));
                  $(this).css('color', '#999999');
               }
            });
            
            $(this).focus(function() {
               if ($(this).val() == $(this).attr("placeholder")) {
                  $(this).val("");
                  $(this).css('color', '');
               }
            });
         }
      });
   }
}
