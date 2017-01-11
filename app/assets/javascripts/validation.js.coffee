class Validation
  constructor: (form_name) ->
    @form_name = form_name

  validate_limit: (limit_form) ->
    $(limit_form).validate
      rules:
        'change_limit[amount]':
          required: true
          number: true
        'mobile':
          required: true
          number: true
      messages:
        'change_limit[amount]':
          required: 'Amount is required'
          number: 'Enter Amount in Numbers'
        'mobile':
          required: 'Mandatory field'
          number: 'Mobile number is invalid'

  validate_search: (search) ->
    $('#startDate').mask '99-99-9999'
    $('#endDate').mask '99-99-9999'
    $(search).validate
      rules:
        'start':
          require_from_group: [1, '.searchTrans']
        'end':
          require_from_group: [1, '.searchTrans']
        'merchant_id':
          require_from_group: [1, '.searchTrans']
      
  validate_request: (request_form) ->
    $(request_form).validate
      rules:
        'request_limit[amount]':
          required: true
          number: true
        'request_limit[bank]':
          required: true
      messages:
        'request_limit[amount]':
          required: 'Amount is required'
          number: 'Enter Amount in Numbers'
        'request_limit[bank]':
          required: 'Bank name is Mandatory'

  validate_change_password: (change_password) ->
    $(change_password).validate
      rules:
        'user[password]':
          required: true
        'user[current_password]':
          required: true
        'user[password_confirmation]':
          required: true
          equalTo: '#user_password'
      messages:
        'user[password_confirmation]':
          required: 'Password confirmation required'
          equalTo: 'Password mismatch'
        'user[password]':
          required: 'Password is required'
        'user[current_password]':
          required: 'Password is required'        


  # $.validator.addMethod 'alphanumeric_check', (value, element) ->
  #   /^(?=.*[a-zA-Z])(?=.*[0-9]).+$/.test value

  # $.validator.addMethod 'mobile_number_check', (value, element) ->
  #   /^[0-9]{10}$/.test value

  # $.validator.addMethod 'alphabetic', (value, element) ->
  #   /^[a-zA-Z\s]+$/.test value

  # $.validator.addMethod 'notOnlyNumbers', (value, element) ->
  #   /(?!^\d+$)^.+$/.test value

window.Validation = Validation
