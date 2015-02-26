# --------------------------------------------------------------------------------

# const
ASPECT = 9 / 16
EVENT_TRANSITION = "transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd"
MONTH_NAMES = ["January", "February", "March", "April", "May", "June",
               "July", "August", "September", "October", "November", "December"]

# var 
isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)

$detail = null
$seekbar= null
$seekpt = null
$msg 	= null

player = null
edl = null
duration = undefined
loadProgress = 0
markerCounter = 0

# --------------------------------------------------------------------------------
# on ready
$ ->
	if isMobile
		changeStatus('mobile')
		alert 'デスクトップでみてね'
		return

	$detail = $('.detail')
	$seekpt = $('.seekbar__seek-point')
	$seekbar= $('.seekbar__highlight')
	$msg 	= $('.cursor-message')

	player = $f( $('.vimeo__iframe')[0] )

	player.addEvent 'ready', ->
		player.addEvent('playProgress', onPlayProgress)
		player.api 'getDuration', (val)->
			duration = val
			if ++markerCounter == 2
				appendMarkers()


		if ++loadProgress == 2
			startPlay()

	# load json
	$.getJSON './data/edl_data.json', (data) ->
		edl = data
		if ++markerCounter == 2
			appendMarkers()
		if ++loadProgress == 2
			startPlay()

	# jQ Event
	$(window).on({
		'keypress':  onKeyPress
		'mousemove': moveCursorMessage
		'resize': 	 fitPlayerToWindow
	}).trigger('mousemove').trigger('resize')

	$('.detail').on 'click', toggleDetail
	$('.seekbar').on
		'mouseover': showSeekPoint
		'mouseout':	 hideSeekPoint 
		'mousemove': moveSeekPoint
		'click': seekTo

# --------------------------------------------------------------------------------
# util
changeStatus = (status, callback) ->
	$('body').attr('data-status', status)
	setTimeout(callback, 300)
	console.log status

getStatus = ->
	$('body').attr('data-status')


# --------------------------------------------------------------------------------
# event
fitPlayerToWindow = ->
	curtAspect = $(window).height() / $(window).width()

	if curtAspect > ASPECT
		$('body').attr('data-orientation', 'portrait')
		width = '100%'
		height = $(window).width() * ASPECT
		top = ($(window).height() - height) / 2
		left = 0
	else
		$('body').attr('data-orientation', 'landscape')
		width = $(window).height() / ASPECT
		height = '100%'
		top = 0
		left = ($(window).width() - width) / 2

	$('.vimeo').css
		top: top
		left: left
		width: width
		height: height

onKeyPress = (evt) ->
	if evt.keyCode == 32 # space
		toggleDetail()
	false

moveCursorMessage = (evt)->
	$msg
		.show()
		.css
			'top': evt.clientY
			'left': evt.clientX

prevProgress = 0
onPlayProgress = (value)->
	$seekbar.css('transform', "scaleX(#{value.percent})")

startPlay = ->
	changeStatus 'playing', ->
		player.api('play')


toggleDetail = ->
	if getStatus() == 'playing'
		pause()
	else if getStatus() == 'detail'
		resume()

seekTo = (evt)->
	seek = evt.clientX / $(window).width() * duration
	player.api('seekTo', seek)
	false

showSeekPoint = ->
	$seekpt.show()
	$msg.html('')


hideSeekPoint = ->
	$seekpt.hide()
	$msg.html('click to show detail')

moveSeekPoint = (evt) ->
	$seekpt.css('left', evt.clientX)

appendMarkers = ->
	$markers = $('.seekbar__markers')
	console.log "we"
	$.each edl, (i, evt)->
		$m = $("<li style=\"left:#{evt.end / duration * 100}%\"></li>")
		$markers.append $m

# --------------------------------------------------------------------------------
# func
pause = ->
	player.api('pause')
	$msg.html('click to resume playing')
	changeStatus 'loading-detail'

	player.api 'getCurrentTime', (time)->
		# retrive current evt
		evt = null
		if time < edl[0].end
			evt = edl[0]
		else 
			for i in [1..edl.length-1]
				if edl[i-1].end < time
					evt = edl[i]

		# load json
		httpJSON = $.getJSON "http://baku89.com/wp-json/posts/#{evt.post_id}", (data)->
			content = data.content.replace(/<img src="/g, '<img src="http://baku89.com')
			content = content.replace(/<a class="lightbox-target" href="(.*?)">/g, "<a>")
			$('.article').html(content)

			cntImg = $('.article img').size()
			loaded = 0

			$('.detail__title a')
				.attr 'href', data.link
				.html data.title
			if data.type == 'work'
				d = new Date(data.date)
				$('.detail__date').html("#{MONTH_NAMES[d.getMonth()]} #{d.getFullYear()}")

			$('.article img').on 'load', ->
				if ++loaded >= cntImg
					changeStatus 'detail'

		httpJSON.error ->
			resume()

resume = ->
	$msg.html('click to show detail')
	changeStatus 'playing', ->
		player.api('play')
		$('.article').html('')
