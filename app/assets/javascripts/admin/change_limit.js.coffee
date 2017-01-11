$(document).ready -> 
  $('#search_distributor').on 'change', (e) ->
    $.ajax
      type: "GET"
      url: '/admin/distributors/search'
      data: { mobile_number: $("#search_distributor").val() }
      dataType: 'json'
      success: (response) ->
        if response.status == 200
          $('#distributor_name').val("#{response.profile.first_name} #{response.profile.last_name}")
        else if response.status == 404
          alert 'Distributor not found, try again'
      error: (jqXHR, textStatus, errorThrown) ->
        alert 'There was some problem fetching the result'

  $('#search_merchant').on 'change', (e) ->
    $.ajax
      type: "GET"
      url: '/admin/merchants/search'
      data: { mobile_number: $("#search_merchant").val() }
      dataType: 'json'
      success: (response) ->
        if response.status == 200
          $('#merchant_name').val("#{response.profile.first_name} #{response.profile.last_name}")
        else if response.status == 404
          alert 'Merchant not found, try again'
      error: (jqXHR, textStatus, errorThrown) ->
        alert 'There was some problem fetching the result'

  $('#search_user').on 'change', (e) ->
    $.ajax
      type: "GET"
      url: '/users/search'
      data: { mobile_number: $("#search_user").val() }
      dataType: 'json'
      success: (response) ->
        if response.status == 200
          $('#user_name').val("#{response.name}")
        else if response.status == 404
          alert 'User not found, try again'
      error: (jqXHR, textStatus, errorThrown) ->
        alert 'There was some problem fetching the result'
