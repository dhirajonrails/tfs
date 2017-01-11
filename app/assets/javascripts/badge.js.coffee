class Badge

  @adminUpdates: ->
    @badgeUpdate()
    @distributorRequestLimitBadgeUpdate()
    @merchantRequestLimitBadgeUpdate()
  
  @badgeUpdate: ->
    $.ajax
      type: "GET"
      url: '/admin/senders/request_notification'
      dataType: 'json'
      success: (response) ->
        $('#view_request_badge')[0].innerText = response.unread_view_requests
        $('#quick_request_badge')[0].innerText= response.unread_quick_requests
      error: (jqXHR, textStatus, errorThrown) ->
        console.log 'error fetching'

  @distributorBadgeUpdate: ->
    $.ajax
      type: "GET"
      url: '/distributors/senders/request_notification'
      dataType: 'json'
      success: (response) ->
        $('#distributorViewRequestBadge')[0].innerText = response.unread_requests
      error: (jqXHR, textStatus, errorThrown) ->
        console.log 'Error fetching the result'

  @distributorRequestLimitBadgeUpdate: ->
    $.ajax
      type: "GET"
      url: '/admin/request_limits/distributors/request_notification'
      dataType: 'json'
      success: (response) ->
        $('#dis_limit_request_badge')[0].innerText = response.unread_requests
      error: (jqXHR, textStatus, errorThrown) ->
        console.log 'Error fetching the result'        

  @merchantRequestLimitBadgeUpdate: ->
    $.ajax
      type: "GET"
      url: '/admin/request_limits/merchants/request_notification'
      dataType: 'json'
      success: (response) ->
        $('#mer_limit_request_badge')[0].innerText = response.unread_requests
      error: (jqXHR, textStatus, errorThrown) ->
        console.log 'Error fetching the result' 

  @distributorMerchantRequestLimitBadgeUpdate: ->
    $.ajax
      type: "GET"
      url: '/distributors/request_limits/request_notification'
      dataType: 'json'
      success: (response) ->
        $('#dis_mer_limit_request_badge')[0].innerText = response.unread_requests
      error: (jqXHR, textStatus, errorThrown) ->
        console.log 'Error fetching the result' 


window.Badge = Badge  