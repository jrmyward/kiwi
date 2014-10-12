FK.App.module "Sidebar", (Sidebar, App, Backbone, Marionette, $, _) ->
  class Sidebar.SubkastFilterView extends Marionette.CompositeView
    template: FK.Template('front_page/sidebar/subkast_filter')
    itemViewContainer: '.subkast-list'
    itemView: Sidebar.SingleSubkastView
    itemViewEventPrefix: 'subkast'
    className: 'subkast-filter filter'
