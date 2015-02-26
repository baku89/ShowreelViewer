var $detail, $msg, $seekbar, $seekpt, ASPECT, EVENT_TRANSITION, MONTH_NAMES, appendMarkers, changeStatus, duration, edl, fitPlayerToWindow, getStatus, hideSeekPoint, isMobile, loadProgress, markerCounter, moveCursorMessage, moveSeekPoint, onKeyPress, onPlayProgress, pause, player, prevProgress, resume, seekTo, showSeekPoint, startPlay, toggleDetail;

ASPECT = 9 / 16;

EVENT_TRANSITION = "transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd";

MONTH_NAMES = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);

$detail = null;

$seekbar = null;

$seekpt = null;

$msg = null;

player = null;

edl = null;

duration = void 0;

loadProgress = 0;

markerCounter = 0;

$(function() {
  if (isMobile) {
    changeStatus('mobile');
    alert('デスクトップでみてね');
    return;
  }
  $detail = $('.detail');
  $seekpt = $('.seekbar__seek-point');
  $seekbar = $('.seekbar__highlight');
  $msg = $('.cursor-message');
  player = $f($('.vimeo__iframe')[0]);
  player.addEvent('ready', function() {
    player.addEvent('playProgress', onPlayProgress);
    player.api('getDuration', function(val) {
      duration = val;
      if (++markerCounter === 2) {
        return appendMarkers();
      }
    });
    if (++loadProgress === 2) {
      return startPlay();
    }
  });
  $.getJSON('./data/edl_data.json', function(data) {
    edl = data;
    if (++markerCounter === 2) {
      appendMarkers();
    }
    if (++loadProgress === 2) {
      return startPlay();
    }
  });
  $(window).on({
    'keypress': onKeyPress,
    'mousemove': moveCursorMessage,
    'resize': fitPlayerToWindow
  }).trigger('mousemove').trigger('resize');
  $('.detail').on('click', toggleDetail);
  return $('.seekbar').on({
    'mouseover': showSeekPoint,
    'mouseout': hideSeekPoint,
    'mousemove': moveSeekPoint,
    'click': seekTo
  });
});

changeStatus = function(status, callback) {
  $('body').attr('data-status', status);
  setTimeout(callback, 300);
  return console.log(status);
};

getStatus = function() {
  return $('body').attr('data-status');
};

fitPlayerToWindow = function() {
  var curtAspect, height, left, top, width;
  curtAspect = $(window).height() / $(window).width();
  if (curtAspect > ASPECT) {
    $('body').attr('data-orientation', 'portrait');
    width = '100%';
    height = $(window).width() * ASPECT;
    top = ($(window).height() - height) / 2;
    left = 0;
  } else {
    $('body').attr('data-orientation', 'landscape');
    width = $(window).height() / ASPECT;
    height = '100%';
    top = 0;
    left = ($(window).width() - width) / 2;
  }
  return $('.vimeo').css({
    top: top,
    left: left,
    width: width,
    height: height
  });
};

onKeyPress = function(evt) {
  if (evt.keyCode === 32) {
    toggleDetail();
  }
  return false;
};

moveCursorMessage = function(evt) {
  return $msg.show().css({
    'top': evt.clientY,
    'left': evt.clientX
  });
};

prevProgress = 0;

onPlayProgress = function(value) {
  return $seekbar.css('transform', "scaleX(" + value.percent + ")");
};

startPlay = function() {
  return changeStatus('playing', function() {
    return player.api('play');
  });
};

toggleDetail = function() {
  if (getStatus() === 'playing') {
    return pause();
  } else if (getStatus() === 'detail') {
    return resume();
  }
};

seekTo = function(evt) {
  var seek;
  seek = evt.clientX / $(window).width() * duration;
  player.api('seekTo', seek);
  return false;
};

showSeekPoint = function() {
  $seekpt.show();
  return $msg.html('');
};

hideSeekPoint = function() {
  $seekpt.hide();
  return $msg.html('click to show detail');
};

moveSeekPoint = function(evt) {
  return $seekpt.css('left', evt.clientX);
};

appendMarkers = function() {
  var $markers;
  $markers = $('.seekbar__markers');
  console.log("we");
  return $.each(edl, function(i, evt) {
    var $m;
    $m = $("<li style=\"left:" + (evt.end / duration * 100) + "%\"></li>");
    return $markers.append($m);
  });
};

pause = function() {
  player.api('pause');
  $msg.html('click to resume playing');
  changeStatus('loading-detail');
  return player.api('getCurrentTime', function(time) {
    var evt, httpJSON, i, j, ref;
    evt = null;
    if (time < edl[0].end) {
      evt = edl[0];
    } else {
      for (i = j = 1, ref = edl.length - 1; 1 <= ref ? j <= ref : j >= ref; i = 1 <= ref ? ++j : --j) {
        if (edl[i - 1].end < time) {
          evt = edl[i];
        }
      }
    }
    httpJSON = $.getJSON("http://baku89.com/wp-json/posts/" + evt.post_id, function(data) {
      var cntImg, content, d, loaded;
      content = data.content.replace(/<img src="/g, '<img src="http://baku89.com');
      content = content.replace(/<a class="lightbox-target" href="(.*?)">/g, "<a>");
      $('.article').html(content);
      cntImg = $('.article img').size();
      loaded = 0;
      $('.detail__title a').attr('href', data.link).html(data.title);
      if (data.type === 'work') {
        d = new Date(data.date);
        $('.detail__date').html(MONTH_NAMES[d.getMonth()] + " " + (d.getFullYear()));
      }
      return $('.article img').on('load', function() {
        if (++loaded >= cntImg) {
          return changeStatus('detail');
        }
      });
    });
    return httpJSON.error(function() {
      return resume();
    });
  });
};

resume = function() {
  $msg.html('click to show detail');
  return changeStatus('playing', function() {
    player.api('play');
    return $('.article').html('');
  });
};
