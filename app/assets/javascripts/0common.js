 var set_size_of;
 set_size_of = function(elem) {
   $(elem).outerWidth(1);
   return $(elem).outerWidth($(elem).parent().innerWidth());
 };
 $(document).ready(function() {
   $("body").css({"cursor": "default"});
   $("a").click(function() {
     $("body").css({"cursor": "wait"});
   });
   $("input[type='submit']").click(function() {
     $("body").css({"cursor": "wait"});
   });
   $("input[readonly!='readonly']").focus(function() {
     $(this).effect('highlight',500);
   });
   $("textarea[readonly!='readonly']").focus(function() {
     $(this).effect('highlight',500);
   });
   /* Activating Best In Place */
   jQuery(".best_in_place").best_in_place();
   
   $("#tech_id").change(function() {
     $("#tech_select").submit();
   });
 });
 
