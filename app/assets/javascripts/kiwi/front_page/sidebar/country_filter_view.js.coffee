FK.App.module "Sidebar", (Sidebar, App, Backbone, Marionette, $, _) ->
  class Sidebar.CountryFilterView extends Marionette.ItemView
    template: FK.Template('front_page/sidebar/country_filter')
    className: 'country-filter filter'
    events:
      'change select': 'save'

    save: (e) =>
      country = @$('option:selected').val()
      @model.setCountry country

      @user = App.request('currentUser')
      if @user
        @user.save('country', country)

    modelEvents:
      'change:country': 'refreshChosenCountry'

    refreshChosenCountry: (model, country) =>
      @$('select').val country

    onRender: =>
      FK.Utils.RenderHelpers.populate_select_getter(@, 'country', FK.Data.countries, 'en_name')
      @refreshChosenCountry(@model, @model.get('country'))
      @$('sup').tooltip({title:'Some events are only relevant within a certain country such as a national holiday or TV show time. Everyone can see events with the Global label.'});
