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
      $('#sort_by_ordered').val('');
   });

   $('#generate').click(function() {
      $('#results').html('');
      showSpinner();

      $.ajax({
         url: "generate.json",
         type: "POST",

         data: {
            courses: $('#courses').val(),
            clash: $('#clash').val(),
            sort_by_ordered: $('#sort_by_ordered').val(),
            force_course: $('#force_course').val(),
            force_course_time: $('#force_course_time').val()
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
         },

         dataType: "json"
      });
   });
});

function showSpinner() {
   $('#spinner_div').show();
}

function hideSpinner() {
   $('#spinner_div').hide();
}

function earliestStartTime(t) {
   var earliest = 24;

   for (var i = 0; i < t.length; i++) {
      for (var name in t[i]) {
         for (var j = 0; j < t[i][name].length; j++) {
            earliest = Math.min(earliest, (t[i][name][j])[1]);
         }
      }
   }

   return earliest;
}

function latestEndTime(t) {
   var latest = 0;

   for (var i = 0; i < t.length; i++) {
      for (var name in t[i]) {
         for (var j = 0; j < t[i][name].length; j++) {
            latest = Math.max(latest, (t[i][name][j])[2]);
         }
      }
   }

   return latest;
}

function timetableToHtml(courses, t) {
   var table = new Array(24);
   for (var i = 0; i < 24; i++) {
      table[i] = new Array(5);
      for (var j = 0; j < 5; j++) {
         table[i][j] = [];
      }
   }

   var start = earliestStartTime(t);
   var finish = latestEndTime(t);

   courses = courses.sort();

   var result = "<table class=\"table table-bordered timetable\">\n";
   result += "<tr><th class=\"hour\">Hour</th><th>Mon</th><th>Tue</th><th>Wed</th><th>Thu</th><th>Fri</th></tr>";
   for (var i = 0; i < t.length; i++) {
      for (var name in t[i]) {
         var times = t[i][name];
         for (var j = 0; j < times.length; j++) {
            for (var k = times[j][1]; k < times[j][2]; k++) {
               table[k][times[j][0]].push(name);
            }
         }
      }
   }

   for (var h = start; h < finish; h++) {
      result += "<tr>";
      result += "<td class=\"hour\">" + h + ":00" + "</td>";

      for (var d = 0; d < 5; d++) {
         if (table[h][d] === '') continue;

         var rowspan = 1;

         if (table[h][d].length >= 1) {
            for (var r = h+1; r < finish; r++) {
               if (!arrayEquals(table[h][d], table[r][d])) break;
               rowspan++;
                
               table[r][d] = '';     
            }
         }

         var cls = "";
         if (table[h][d].length >= 1) {
            if (table[h][d].length > 1) {
               cls = "clash";
            } else {
               cls = "class colour" + (courses.indexOf(table[h][d][0].split(' ')[0]) + 1).toString();
            }
         }

         if (rowspan > 1) {
           result += "<td rowspan=\"" + rowspan + "\" class=\"" + cls + "\">";
         } else {
           result += "<td class=\"" + cls + "\">";
         }

         result += table[h][d].join(" + ") + "</td>";
     }

     result += "</tr>";
   }

   result += "</table>\n";

   return result;
}

function arrayEquals(a,b) {
   if (a.length != b.length) return false;

   for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
   }

   return true;
}

