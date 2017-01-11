class SenderRegister

  init: ->
    self = this
    @bindEvent(self)
    window.validateForm = true

   
  bindEvent: (self)-> 
    $('#userRegisterForm').on 'submit', (e) ->
      e.prevenDefault
      if window.validateForm == true
        $('#userRegisterForm')[0].submit()
      else
        e.prevenDefault
        alert 'form cannot be validated, please check the fields'

    # $('#beneficiaryAccount').on 'focusout', (e)->
    #   unless $(this)[0].hasAttribute('readonly')
    #     if e.currentTarget.value != ""
    #       $.ajax
    #         type: "GET"
    #         url: '/senders/validate_account'
    #         data: { account_number: $("#beneficiaryAccount").val() }
    #         dataType: 'json'
    #         success: (response) ->
    #           if response.status == 200
    #             $('#beneficiaryAccount').val('')
    #             $('#beneficiaryAccount').focus()
    #             window.validateForm = false
    #             alert 'Account Already Registered'
    #           else if response.status == 404
    #             window.validateForm = true
    #         error: (jqXHR, textStatus, errorThrown) ->
    #           alert 'There was some error validating Account Number'

    # $('#senderMobile').on 'focusout', (e)->
    #   unless $(this)[0].hasAttribute('readonly')
    #     if e.currentTarget.value != ""
    #       $.ajax
    #         type: "GET"
    #         url: '/senders/validate_number'
    #         data: { mobile: $("#senderMobile").val() }
    #         dataType: 'json'
    #         success: (response) ->
    #           if response.status == 200
    #             $('#senderMobile').val('')
    #             $('#senderMobile').focus()
    #             window.validateForm = false
    #             alert 'Mobile Already Registered'
    #           else if response.status == 404
    #             window.validateForm = true
    #             return true
    #         error: (jqXHR, textStatus, errorThrown) ->
    #           alert 'There was some error validating mobile Number'

    $('#exisingRegister').on 'click', (e)->
      $('.registerBox').addClass('hide')
      $("#searchByAccount").val('')
      $("#searchByMobile").val('')
      $('#userRegisterForm')[0].reset()
      $('#searchSender').show()

    $('#newRegister').on 'click', (e) ->
      $('.registerBox').removeClass('hide')
      $('#existingBenData').addClass('hide')
      $('#existingSenderData').addClass('hide')
      $("input.beneficiaryRegister").removeAttr('readonly')
      $("input.senderRegister:text").removeAttr('readonly')
      $('#userRegisterForm')[0].reset()
      $('#searchSender').hide()
    
    $('#searchMobileBtn').on 'click', (e) ->
      $('.registerBox').removeClass('hide')
      $('#existingSenderData').addClass('hide')
      $('#existingBeneficiary').addClass('hide')
      $(this).attr('readonly', 'readonly')
      $("input.beneficiaryRegister").removeAttr('readonly')
      $("input.senderRegister:text").removeAttr('readonly')
      $.ajax
        type: "GET"
        url: '/senders/search_by_mobile'
        data: { mobile: $("#searchByMobile").val() }
        dataType: 'json'
        success: (response) ->
          $('#existingBenData').removeClass('hide')
          $("#searchByAccount").val('')
          $('#userRegisterForm')[0].reset()
          if response.status == 200
            sender = response.sender
            $('#senderName').val(sender.name)
            $('#sender_id_proof').val(sender.id_proof)
            $('#senderAddress').val(sender.address)
            $('#senderMobile').val(sender.mobile)
            # $("input.senderRegister:text").attr('readonly', 'readonly')
          else if response.status == 404
            $('#senderRegisterBox').addClass('hide')
            $('#beneficiaryRegisterBox').addClass('hide')            
            $('#existingBenData').addClass('hide')
            $("#searchByMobile").val('')
            alert 'Sender Not Found'
        error: (jqXHR, textStatus, errorThrown) ->
          $('.registerBox').addClass('hide')
          $('#existingBenData').addClass('hide')
          $("#searchByMobile").val('')
          alert 'There was some problem fetching the result'
      $(this).removeAttr('readonly')

    $('#searchByAccountBtn').on 'click', (e) ->
      # $('.registerBox').removeClass('hide')
      $(this).attr('readonly', 'readonly')
      $('#existingSenderData').removeClass('hide')
      $('#existingBenData').addClass('hide')
      $('#existingSender').addClass('hide')
      $("input.beneficiaryRegister").removeAttr('readonly')
      $("input.senderRegister:text").removeAttr('readonly')
      $('#transfer_amount_total').attr('readonly', 'readonly')
      $.ajax
        type: "GET"
        url: '/senders/search_by_account_number'
        data: { account_number: $("#searchByAccount").val() }
        dataType: 'json'
        success: (response) ->
          $("#searchByMobile").val('')
          $('#userRegisterForm')[0].reset()
          if response.status == 200
            $('.registerBox').removeClass('hide')
            beneficiary = response.beneficiary
            sender = response.sender
            bank_detail = response.bank_detail
            
            $('#beneficiaryName').val(beneficiary.name)
            $('#beneficiaryAccount').val(beneficiary.account_number)
            $('#ifscCode').val(bank_detail.ifsc_code)
            $('#bankName').val(bank_detail.name)
            $('#bankState').val(bank_detail.state)
            $('#bankDistrict').val(bank_detail.district)
            $('#bankCity').val(bank_detail.city)
            $('#bankBranch').val(bank_detail.branch)
            $('#bankAddress').val(bank_detail.address)
            # $("input.beneficiaryRegister").attr('readonly', 'readonly')
          else if response.status == 404
            $('.registerBox').addClass('hide')
            $("#searchByAccount").val('')
            alert 'No Data Found'
        error: (jqXHR, textStatus, errorThrown) ->
          $('#senderRegisterBox').addClass('hide')
          $('#beneficiaryRegisterBox').addClass('hide')          
          alert 'There was some problem fetching the result'              
      $(this).removeAttr('readonly')
         

    $('#existingSenderCheck').on 'click', (e) ->
      if e.currentTarget.checked
        # $("input.beneficiaryRegister:text").attr('readonly', 'readonly')
        $('#existingSender').removeClass('hide')
        $('#existingSender').html('<option value="" default selected>select a sender</option>')
        $.ajax
          type: "GET"
          url: '/senders/existing_senders'
          data: { account_number: $("#searchByAccount").val() }
          dataType: 'json'
          success: (response) ->
            $.each response.senders, (i, sender) ->
              $('#existingSender').append $('<option>',
                value: sender.mobile
                text: "#{sender.name} mobile: #{sender.mobile}"
                )
          error: (jqXHR, textStatus, errorThrown) ->
            $('#existingSender').addClass('hide')
            alert 'There was some problem fetching the result'
            $("input.beneficiaryRegister:text").val("")
            $("input.beneficiaryRegister:text").removeAttr('readonly')
            $('#existingSender').addClass('hide')              
      else
        $('#existingSender').addClass('hide')  
        $("input.senderRegister:text").val("")
        $("input.senderRegister:text").removeAttr('readonly')


    $('#existingBeneficiaryCheck').on 'click', (e) ->
      if e.currentTarget.checked
        # $("input.beneficiaryRegister:text").attr('readonly', 'readonly')
        $('#existingBeneficiary').removeClass('hide')
        $('#existingBeneficiaryFill').html ''
        $.ajax
          type: "GET"
          url: '/senders/beneficiaries'
          data: { mobile: $("#senderMobile").val() }
          dataType: 'json'
          success: (response) ->
            $.each response.beneficiaries, (i, beneficiary) ->
              $('#existingBeneficiaryFill').append("<li>
                <span><input type='button' class='deleteBeneficiary' data-acno='#{beneficiary.account_number}' value='X' /></span>  
                <span><input type='button' class='selectBeneficiary' data-acno='#{beneficiary.account_number}' value = '#{beneficiary.name} acc_no: #{beneficiary.account_number}'/></span></li>")
          error: (jqXHR, textStatus, errorThrown) ->
            $('#existingBeneficiary').addClass('hide')
            alert 'There was some problem fetching the result'
            $("input.beneficiaryRegister").val("")
            $("input.beneficiaryRegister").removeAttr('readonly')
            $('#existingBeneficiary').addClass('hide')              
      else
        $("input.beneficiaryRegister").val("")
        $("input.beneficiaryRegister").removeAttr('readonly')
        $('#existingBeneficiary').addClass('hide')  


    $('#resetRegister').on 'click', ->
      $('.registerBox').addClass('hide')
      $('#existingBenData').addClass('hide')
      $('#existingSenderData').addClass('hide')
      $('#userRegisterForm')[0].reset()
      $("#searchByAccount").val('')
      $("#searchByMobile").val('')


    $('#check_bank').on 'click', ->
      $.ajax
        type: "GET"
        url: '/senders/search_bank_detail'
        data: { ifsc: $("#ifscCode").val() }
        dataType: 'json'
        success: (response) ->
          if response.status == 200
            bank_detail = response.bank_detail

            $('#ifscCode').val(bank_detail.ifsc_code)
            $('#bankName').val(bank_detail.name)
            $('#bankState').val(bank_detail.state)
            $('#bankDistrict').val(bank_detail.district)
            $('#bankCity').val(bank_detail.city)
            $('#bankBranch').val(bank_detail.branch)
            $('#bankAddress').val(bank_detail.address)
          else if response.status == 404
            alert 'No Bank Found with this IFSC CODE'
        error: (jqXHR, textStatus, errorThrown) ->
          alert 'There was some problem fetching the result'

    $('#amount_to_transfer').on 'focusout', (e)->
      amount = $("#amount_to_transfer").val()
      quick_transfer = $('#transaction_quick_transfer')[0].checked ? true : false
      $.ajax
        type: "GET"
        url: '/senders/charge'
        data: { amount: amount, quick_transfer: quick_transfer }
        dataType: 'json'
        success: (response) ->
          if response.status == 200
            $('#transfer_amount_total').val(response.total)
          else if response.status == 404
            $('#amount_to_transfer').val('')
            alert 'enter correct ammount'
        error: (jqXHR, textStatus, errorThrown) ->
          alert 'There was some error fetching the charge'

    $('#transaction_quick_transfer').on 'click', (e)->
      amount = $("#amount_to_transfer").val()
      quick_transfer = $('#transaction_quick_transfer')[0].checked ? true : false
      $.ajax
        type: "GET"
        url: '/senders/charge'
        data: { amount: amount, quick_transfer: quick_transfer }
        dataType: 'json'
        success: (response) ->
          if response.status == 200
            $('#transfer_amount_total').val(response.total)
          else if response.status == 404
            $('#amount_to_transfer').val('')
            alert 'enter correct ammount'
        error: (jqXHR, textStatus, errorThrown) ->
          alert 'There was some error fetching the charge'

    $(document).on 'click','.selectBeneficiary', (e)->
      ac_no = this.dataset.acno
      $.ajax
        type: "GET"
        url: '/senders/search_by_account_number'
        data: { account_number: ac_no }
        dataType: 'json'
        success: (response) ->
          if response.status == 200
            beneficiary = response.beneficiary
            bank_detail = response.bank_detail

            $('#beneficiaryName').val(beneficiary.name)
            
            $('#beneficiaryAccount').val(beneficiary.account_number)
            
            $('#ifscCode').val(bank_detail.ifsc_code)

            $('#bankName').val(bank_detail.name)

            $('#bankState').val(bank_detail.state)

            $('#bankDistrict').val(bank_detail.district)

            $('#bankCity').val(bank_detail.city)

            $('#bankBranch').val(bank_detail.branch)

            $('#bankAddress').val(bank_detail.address)
            # $('#beneficiaryName').attr('readonly', 'readonly')
            # $('#beneficiaryAccount').attr('readonly', 'readonly')
            # $('#ifscCode').attr('readonly', 'readonly')
            # $('#bankName').attr('readonly', 'readonly')
            # $('#bankState').attr('readonly', 'readonly')
            # $('#bankDistrict').attr('readonly', 'readonly')
            # $('#bankCity').attr('readonly', 'readonly')
            # $('#bankBranch').attr('readonly', 'readonly') 
            # $('#bankAddress').attr('readonly', 'readonly')

          else if response.status == 404
            $("input.beneficiaryRegister").val("")
            $("input.beneficiaryRegister").removeAttr('readonly')
            $('#existingBeneficiary').addClass('hide')                        
            alert 'No Data Found'
        error: (jqXHR, textStatus, errorThrown) ->
          alert 'There was some problem fetching the result'


    $(document).on 'click','.deleteBeneficiary', (e)->
      if confirm('Are you sure')
        ac_no = this.dataset.acno
        $.ajax
          type: "GET"
          url: '/senders/delete_beneficiary'
          data: { account_number: ac_no, mobile: $('#senderMobile').val() }
          dataType: 'json'
          success: (response) ->
            window.location.href = location.href
            # if response.status == 200
            #   $('#existingBeneficiaryFill').html ''
            #   $.each response.beneficiaries, (i, beneficiary) ->
            #     $('#existingBeneficiaryFill').append("<li>
            #       <span><input type='button' class='deleteBeneficiary' data-acno='#{beneficiary.account_number}' value='X' /></span>  
            #       <span><input type='button' class='selectBeneficiary' data-acno='#{beneficiary.account_number}' value = '#{beneficiary.name} acc_no: #{beneficiary.account_number}'/></span></li>")
          error: (jqXHR, textStatus, errorThrown) ->
            alert 'there is some problem deleting the beneficiary'

  @getSenderDetail: (mobile_no) ->
    $.ajax
      type: "GET"
      url: '/senders/search_sender_detail'
      data: { mobile: mobile_no }
      dataType: 'json'
      success: (response) ->
        if response.status == 200
          sender = response.sender

          $('#senderName').val(sender.name)
          $('#sender_id_proof').val(sender.id_proof)
          $('#senderAddress').val(sender.address)
          $('#senderMobile').val(sender.mobile)
          # $("input.senderRegister:text").attr('readonly', 'readonly')

        else if response.status == 404
          $("input.senderRegister:text").val("")
          $("input.senderRegister:text").removeAttr('readonly')
          $('#existingSender').addClass('hide')                        
          alert 'No Data Found'
      error: (jqXHR, textStatus, errorThrown) ->
        alert 'There was some problem fetching the result'              


window.SenderRegister = SenderRegister       