$ ->
  class ohvideos
    constructor: (@width = 480, @height = 270, @sites) ->

      @masterDiv = $('.oharaEmbed')
      @basedElement = @masterDiv.parent()
      @aspectRatio = @height / @width
      @main()
      @responsive()

    main: () ->
      $.each @sites, (site) =>
        $.each "." + site.identifier, (video) =>
          video.domElement = $(this)
          video = $.extend(video, $.parseJSON(decodeURIComponent(video.domElement.data('ohara_'+ site.identifier))))
          video.embedUrl = site.embedUrl.replace('{video_id}', video.video_id)
          video.requestUrl = site.requestUrl.replace('{video_id}', video.video_id)

          video = @.getData(video)
          video = @.createVideo(video)

      @.responsive()

    createVideo: (video) ->
      vDiv = $('<div/>')
      vDiv.attr class: "oharaEmbed_play"
      video.domElement.append vDiv
      video.domElement.on "click", =>
        $(this).html (video) =>
          iframe = $('<iframe/>')
          iframe
           frameborder: '0'
           src: video.embedUrl
           width: @width
           height: @height
           allowfullscreen: ''
           class: "oharaEmbedIframe"

      video

    getData: (video) ->
      title = $('<div/>')
      title.attr class: "oharaEmbed_title"
      $.ajax "//noembed.com/embed",
        url: video.requestUrl
        type: 'GET'
        dataType: 'json'
        error: (jqXHR, textStatus, errorThrown) ->
            title.html(textStatus)
        success: (data, textStatus, jqXHR) ->
          title.html(data.title)
          video.domElement.css background-image: 'url('+ data.thumbnail_url +')', background-size: 'cover'

      video.domElement.append(title)
      video

    responsive: () =>
      do $(window).resize () ->
        # Get the new width and height
        newWidth = @basedElement.width()
        newHeight = Math.min newWidth * @aspectRatio, @height

        # If the new width is lower than the "default width" then apply some resizing. No? then go back to our default sizes
        applyResize = (newWidth <= @width)
        applyWidth = newWidth if applyResize else @width
        applyHeight = newHeight if applyResize else @height

        # Do the thing already
        @masterDiv.width applyWidth
        @masterDiv.height applyHeight

        # The iframe too!
        $('iframe.oharaEmbedIframe').each () =>
          $(this).width applyWidth
          $(this).height(applyHeight)

    refresh: (timeWait) =>
      setTimeout =>
        @main()
        @responsive()
      , timeWait || 3e3

  oh_refresh (timeWait) ->
    ohObject = ohObject || new ohvideos()
