var originalCoord={x:0,y:0}
var finalCoord={x:0,y:0}
function touchStart(event){originalCoord.x=event.targetTouches[0].pageX
  originalCoord.y=event.targetTouches[0].pageY}
function touchMove(event){finalCoord.x=event.targetTouches[0].pageX
  finalCoord.y=event.targetTouches[0].pageY;if(Math.abs(finalCoord.y-originalCoord.y)<touchdefaults.threshold.y)event.preventDefault();}
function touchEnd(event){var changeY=originalCoord.y- finalCoord.y
  if(changeY<touchdefaults.threshold.y&&changeY>(touchdefaults.threshold.y*-1)){changeX=originalCoord.x- finalCoord.x
	  if(changeX>touchdefaults.threshold.x){touchdefaults.swipeLeft()}
	  if(changeX<(touchdefaults.threshold.x*-1)){touchdefaults.swipeRight()}}}
function touchStart(event){originalCoord.x=event.targetTouches[0].pageX
  originalCoord.y=event.targetTouches[0].pageY
  finalCoord.x=originalCoord.x
  finalCoord.y=originalCoord.y}

function startup() {
	var el = document.getElementsByClassName("top_navi")[0];
	el.addEventListener("touchstart", touchStart, false);
	el.addEventListener("touchend", touchEnd, false);
	el.addEventListener("touchleave", touchEnd, false);
	el.addEventListener("touchmove", touchMove, false);
}

