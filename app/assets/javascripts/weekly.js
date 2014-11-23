//= require jquery
//= require weekly/mc-validation
//= require weekly/smoothscroll.js
//= require weekly/jquery.lettering-0.6.min.js
//= require weekly/circletype.js
//= require weekly/jquery.fittext.js


$(document).scroll(function () {
    var y = $(this).scrollTop();
    if (y > 400) {
        $('#navigation').fadeIn();
    } else {
        $('#navigation').fadeOut();
    }
});

$(document).ready(function() {
    $(".curve-text").lettering();
  });

$(document).ready(function() {
	$(".curve-text").circleType({fitText: true, radius: 2000});
  });
