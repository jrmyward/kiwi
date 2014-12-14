$ ->
  $('[name="name"]').keyup((e) =>
    val = $(e.target).val()

    remaining_count = 100 - val.length

    $('[data-role="counter"]').text(remaining_count)
  )
