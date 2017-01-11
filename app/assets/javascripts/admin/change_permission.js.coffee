$(document).ready ->
  $('#submit_permission').on 'click', (e) ->
    $('#submit_permission').attr('disabled', 'disabled')
    selected_permissions = []
    $.each $('.permissionCheck:checked'), (i, option) ->
      selected_permissions.push(option.dataset.id)
    permissions = 
      selected_permissions: selected_permissions
      admin_id: $('#permissionModal')[0].dataset.userId  
    $.ajax
      type: "POST"
      url: '/change_permissions'
      data: { permissions: permissions }
      dataType: 'json'
      success: (response) ->
        $('#submit_permission').removeAttr('disabled')
        $('#permissionModal').modal('toggle')

  $('#permissionModal').on 'hidden.bs.modal', (e) ->
    $('.permissionCheck').attr('checked', false)

  $('#newAdminForm').on 'submit', (e) ->
    e.preventDefault()
    $('#create_admin').attr('disabled', 'disabled')
    $.ajax
      type: "POST"
      url: '/create_admin'
      data: $('#newAdminForm').serialize()
      dataType: 'json'
      success: (response) ->
        $('input[type="submit"]').removeAttr('disabled')
        $('#create_admin').removeAttr('disabled')
        $("#newAdminForm")[0].reset()
        $('#addAdminModal').modal('toggle')
        $('#messageAlertModal').modal('toggle')
        $('#messageAlertBody').html("#{response.user.admin.profile.first_name.toUpperCase()} #{response.user.admin.profile.last_name.toUpperCase()} added as an Admin.")
        add_role_button = "<a class='permitButton' data-target='#permissionModal' data-toggle='modal' data-user-id='#{response.user.id}' href='#'>
                            <span class='label label-info arrowed-right arrowed-in'>Add Permission</span>
                          </a>"
        $('#messageAlertBody').append(add_role_button)
        record = "<tr>
                  <td>
                    #{response.user.admin.profile.first_name} #{response.user.admin.profile.last_name}
                  </td>
                  <td>
                    <b class='green'>
                      #{response.user.mobile}
                    </b>
                  </td>
                  <td class='hidden-480'>
                    <a class='permitButton' data-target='#permissionModal' data-toggle='modal' data-user-id=#{response.user.id} href='#'>
                      <span class='label label-info arrowed-right arrowed-in'>Permission</span>
                    </a>
                  </td>
                  <td class='hidden-480'>
                    <span class='adminLimitButton' data-target='#adminLimitModal' data-toggle='modal' data-user-id=#{response.user.id} href='#'>
                      <i class='icon-only ace-icon fa fa-share'/>
                    </span>
                  </td>
                </tr>
              "        
        $('#adminUsersTbody').prepend(record)
      error: (response) ->
        $('input[type="submit"]').removeAttr('disabled')
        $('#create_admin').removeAttr('disabled')
        $("#newAdminForm")[0].reset()
        $('#addAdminModal').modal('toggle')
        $('#messageAlertBody').html(' Error creating user, try again!!')
        $('#messageAlertModal').modal('toggle')

  $(document).on 'click', '.permitButton',  (event) ->
    if $('#messageAlertModal').is(':visible')
      $('#messageAlertModal').modal('toggle')
    $('#permissionModal')[0].dataset.userId = event.target.parentElement.dataset.userId
    $.ajax
      type: "GET"
      url: '/admin_details'
      data: { id: event.target.parentElement.dataset.userId }
      dataType: 'json'
      success: (response) ->
        $('#adminName').text("#{response.admin.admin.profile.first_name.toUpperCase()} #{response.admin.admin.profile.last_name.toUpperCase()}")
        $.each response.admin.roles, (i, role) ->
          unless $(".permissionCheck[data-id='#{role.id}']").is(':checked')
            $(".permissionCheck[data-id='#{role.id}']").prop('checked', true)

  $(document).on 'click', '.adminLimitButton',  (event) ->
    if $('#messageAlertModal').is(':visible')
      $('#messageAlertModal').modal('toggle')
    $('#adminLimitModal')[0].dataset.userId = event.currentTarget.dataset.userId
    admin_id = event.currentTarget.dataset.userId
    $.ajax
      type: "GET"
      url: '/admin_details'
      data: { id: admin_id }
      dataType: 'json'
      success: (response) ->
        $('#adminNameLimit').text("#{response.admin.admin.profile.first_name.toUpperCase()} #{response.admin.admin.profile.last_name.toUpperCase()}")
        $('#currentAdminLimit').val("#{response.admin.admin.balance_limit}")
        $('#newAdminLimit').val("#{response.admin.admin.balance_limit}")

  $(document).on 'change keyup', '#adminLimitAmount',  (event) ->
    unless $(this).val() == ''
      $('#newAdminLimit').val parseInt($(this).val()) + parseInt($('#currentAdminLimit').val())
    else
      $('#newAdminLimit').val $('#currentAdminLimit').val()

  $('#addAdminLimitForm').on 'submit', (e) ->
    e.preventDefault()
    $('#addAdminLimitSubmit').attr('disabled', 'disabled')
    $.ajax
      type: "POST"
      url: '/add_admin_limit'
      data: { id: $('#adminLimitModal')[0].dataset.userId, limit: $('#adminLimitAmount').val() }
      dataType: 'json'
      success: (response) ->
        $('#addAdminLimitSubmit').removeAttr('disabled')
        $('#addAdminLimitForm')[0].reset()
        $('#adminLimitModal').modal('toggle')
        $('#messageAlertBody').html("Added #{response.amount} to #{response.admin.admin.profile.first_name.toUpperCase()} #{response.admin.admin.profile.last_name.toUpperCase()}")
        $('#messageAlertModal').modal('toggle')
      error: ->
        $('#addAdminLimitSubmit').removeAttr('disabled')
        $('#adminLimitModal').modal('toggle')
        $('#messageAlertBody').html(' Error adding limit, try again!!')
        $('#messageAlertModal').modal('toggle')
