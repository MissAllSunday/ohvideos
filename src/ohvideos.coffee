$ ->
  class _oh
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
