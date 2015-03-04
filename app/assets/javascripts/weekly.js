//= require jquery

var animateIntegrations = function() {
    var integrationSequence = 0,
        integrationLimit = jQuery(".em-integration li").length - 1;
    setInterval(function() {
        jQuery(".em-integration li").eq(integrationSequence).hide(),
            integrationSequence = integrationSequence ==
            integrationLimit ? 0 : integrationSequence + 1, jQuery(
                ".em-integration li").eq(integrationSequence).fadeIn()
    }, 1e3)
};
jQuery(document).on("ready", function() {
    animateIntegrations()
});