$(document).ready ->  
  $('#search_dis_merchant').on 'change', (e) ->
    e.preventDefault()
    $.ajax
      type: "GET"
      url: '/distributors/merchants/search'
      data: { mobile_number: $("#search_dis_merchant").val() }
      dataType: 'json'
      success: (response) ->
        if response.status == 200
          $('#merchant_name').val("#{response.profile.first_name} #{response.profile.last_name}")
        else if response.status == 404
          alert 'Merchant not found, try again'
      error: (jqXHR, textStatus, errorThrown) ->
        alert 'There was some problem fetching the result'