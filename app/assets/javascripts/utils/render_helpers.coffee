class FK.Utils.RenderHelpers
  @populate_checkboxes_from_array: (view, container, arr, klass) ->
    view.$el.find(container).html(_.map(arr,(item) =>
      "<div class=\"checkbox #{klass}\">
        <label class=\"#{klass}\">
          <input type=\"checkbox\" name=\"#{item.value}\" />
         #{item.option}
        </label>
      </div>").join(''))

  @populate_select_getter: (view, property, collection, label) ->
    view.$el.find("select[name=#{property}]").html(collection.map((item) =>
      selected = (if (view.model && view.model.get(property) is item.get('_id')) then " selected=\"selected\" " else "")
      "<option value=\"#{item.get('_id')}\" #{selected} >#{item.get(label)}</option>").join(''))
