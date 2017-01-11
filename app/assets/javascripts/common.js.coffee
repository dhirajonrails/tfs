$(document).on 'ready page:load', ->
  $('form').on 'submit', (e)->
    if $(this).valid() && !$(this).hasClass('download-form')
      $('input[type="submit"]').attr('disabled', 'disabled')

  $('.delete').on 'click',  (e) ->
    unless confirm('Are You sure?')
      e.preventDefault()  
      return false
    else
      return true

  $('.date-picker').datepicker
    changeMonth: true,
    changeYear: true,
    dateFormat: 'dd-mm-yy',
    maxDate: 0

  setTimeout '$(".alert").hide("")', 4000