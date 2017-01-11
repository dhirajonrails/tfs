
class TransactionDetails
  Transaction =  undefined
  settings:
    getTransactions: -> $('#transactionTemplate')
    transactions: $('.transactionContent').data('transaction-list')
    transactionList: -> $('#transactionDetails')

  init: ->
    Transaction = @settings
    @bindUIActions(this)
    @initialTransactionFetch()
    $('.transactionContent').removeAttr('data-transaction-list')

  initialTransactionFetch: ->
    ghtml = _.template(Transaction.getTransactions().html(), { transactions: Transaction.transactions })
    $('#transactionDetails').html(ghtml)

  bindUIActions: (self)-> 
    $(document).on "click",".selectAll", (e) ->
      self.customCheckAll(e)

    $(document).on "click",".selectBox", (e) ->    
      self.customCheckBox(e)

    $(document).on 'click','#multi_status_change_done', (e) ->
      transactions = []
      $('.selectBox:checkbox:checked').each ->
        transactions.push this.value
      $.ajax
        type: "POST"
        url: '/admin/senders/bulk_status_update'
        data: { transaction_ids: transactions }
        dataType: 'json'
        success: (response) ->
          window.location.href = window.location.href
        error: (jqXHR, textStatus, errorThrown) ->
          console.log 'error updating status'      


  customCheckAll: (e) ->
    if $('.selectAll').prop('checked')
      $(e.target).parent(".checkboxWrap").toggleClass 'checked'
      $('.selectBox').prop('checked', true)
      $('.selectBox').parent(".checkboxWrap").addClass 'checked'
    else
      $('.selectBox').prop('checked', false)
      $(e.target).parent(".checkboxWrap").removeClass 'partially checked'
      $('.selectBox').parent(".checkboxWrap").removeClass 'checked'
    return

  customCheckBox: (e) ->
    if $(".selectBox").is(':checked')
      $('.selectAll').prop('checked', false)
      $(e.target).parent(".checkboxWrap").toggleClass 'checked'
      $('.selectAll').parent(".checkboxWrap").addClass 'partially'
    else
      $('.selectAll').prop('checked', false)
      $(e.target).parent(".checkboxWrap").toggleClass 'checked'
      $('.selectAll').parent(".checkboxWrap").removeClass 'checked partially'


window.TransactionDetails = TransactionDetails
