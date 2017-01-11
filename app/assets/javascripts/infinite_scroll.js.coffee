$ ->
  isLoadingNextPage = false  # keep from loading two pages at once

  nextPage = (viewMore, link)->
    url = viewMore.find('a').attr('href')
    return if isLoadingNextPage || !url
    url = url.split('?')
    url[0] = link
    url = url.join('?')

    viewMore.addClass('loading')
    isLoadingNextPage = true

    $.ajax({
      url: url,
      method: 'GET',
      dataType: 'script',
      success: ->
        viewMore.removeClass('loading');
        isLoadingNextPage = false;
        lastLoadAt = new Date();
    })

  $(document).ready ->
    $('#distributorLimitHistory').find('.scroll-content').bind 'scroll', ->
      if $(this).scrollTop() + $(this).innerHeight()>=$(this)[0].scrollHeight - 5
        nextPage($('#view-more-distributor-log'), '/admin/distributors/logs')

    $('#merchantLimitHistory').find('.scroll-content').bind 'scroll', ->
      if $(this).scrollTop() + $(this).innerHeight()>=$(this)[0].scrollHeight - 5
        nextPage($('#view-more-merchant-log'), '/admin/merchants/logs')

    $('#distributorList').find('.scroll-content').bind 'scroll', ->
      if $(this).scrollTop() + $(this).innerHeight()>=$(this)[0].scrollHeight - 5
        nextPage($('#view-more-distributor'), '/admin/distributors')


    $('#merchantList').find('.scroll-content').bind 'scroll', ->
      if $(this).scrollTop() + $(this).innerHeight()>=$(this)[0].scrollHeight - 5
        nextPage($('#view-more-merchant'), '/admin/merchants')


  $('#view-more-distributor-log').find('a').click (e) ->
    nextPage($('#view-more-distributor-log'), '/admin/distributors/logs')
    e.preventDefault()

  $('#view-more-merchant-log').find('a').click (e) ->
    nextPage($('#view-more-merchant-log'), '/admin/merchants/logs')
    e.preventDefault()

  $('#view-more-distributor').find('a').click (e) ->
    nextPage($('#view-more-distributor'), '/admin/distributors')
    e.preventDefault()

  $('#view-more-merchant').find('a').click (e) ->
    nextPage($('#view-more-merchant'), '/admin/merchants')
    e.preventDefault()
