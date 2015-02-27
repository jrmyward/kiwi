//= require jquery_cookie

$(document).ready(function() {
    var closedNewsletterBar = $.cookie('forekast_closed_newsletter_bar');
    if (closedNewsletterBar === 'true') {
        $('.newsletter-bar').remove();
    }
    else {
    	$('.newsletter-bar').removeClass('hidden');
        $('.newsletter-close-button').on('click', function() { 
            $('.newsletter-bar').remove(); 
            $.cookie('forekast_closed_newsletter_bar', 'true', { expires: 50*365, path: '/' });
        });
    }
});