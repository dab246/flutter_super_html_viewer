
import 'package:flutter_super_html_viewer/utils/html_event_action.dart';

class HtmlUtils {

  static const scrollEventJSChannelName = 'ScrollEventListener';
  static const nameClassToolTip = 'tmail-tooltip';

  static String generateHtmlDocument(String content, {
    double? minHeight,
    double? minWidth,
    String? styleCSS,
    String? javaScripts,
    bool hideScrollBar = true,
  }) {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
      <style>
        .tmail-content {
          min-height: ${minHeight ?? 0}px;
          min-width: ${minWidth ?? 0}px;
          overflow: auto;
        }
        ${hideScrollBar ? '''
          .tmail-content::-webkit-scrollbar {
            display: none;
          }
          .tmail-content {
            -ms-overflow-style: none;  /* IE and Edge */
            scrollbar-width: none;  /* Firefox */
          }
        ''' : ''}
        ${styleCSS ?? ''}
      </style>
      ${javaScripts ?? ''}
      </head>
      <body>
      <div class="tmail-content">$content</div>
      </body>
      </html> 
    ''';
  }

  static const runScriptsHandleScrollEvent = '''
    let contentElement = document.getElementsByClassName('tmail-content')[0];
    var xDown = null;                                                        
    var yDown = null;
    
    contentElement.addEventListener('touchstart', handleTouchStart, false);
    contentElement.addEventListener('touchmove', handleTouchMove, false);
    
    function getTouches(evt) {
      return evt.touches || evt.originalEvent.touches;
    }                                                     
                                                                             
    function handleTouchStart(evt) {
      const firstTouch = getTouches(evt)[0];                                      
      xDown = firstTouch.clientX;                                      
      yDown = firstTouch.clientY;                                     
    }                                               
                                                                             
    function handleTouchMove(evt) {
      if (!xDown || !yDown) {
        return;
      }
  
      var xUp = evt.touches[0].clientX;                                    
      var yUp = evt.touches[0].clientY;
  
      var xDiff = xDown - xUp;
      var yDiff = yDown - yUp;
                                                                           
      if (Math.abs(xDiff) > Math.abs(yDiff)) {
        let newScrollLeft = contentElement.scrollLeft;
        let scrollWidth = contentElement.scrollWidth;
        let offsetWidth = contentElement.offsetWidth;
        let maxOffset = Math.round(scrollWidth - offsetWidth);
        let scrollLeftRounded = Math.round(newScrollLeft);
         
        /*  
          console.log('newScrollLeft: ' + newScrollLeft);
          console.log('scrollWidth: ' + scrollWidth);
          console.log('offsetWidth: ' + offsetWidth);
          console.log('maxOffset: ' + maxOffset);
          console.log('scrollLeftRounded: ' + scrollLeftRounded); */
          
        if (xDiff > 0) {
          if (maxOffset === scrollLeftRounded || 
              maxOffset === (scrollLeftRounded + 1) || 
              maxOffset === (scrollLeftRounded - 1)) {
            window.$scrollEventJSChannelName.postMessage('${HtmlEventAction.scrollRightEndAction}');
          }
        } else {
          if (scrollLeftRounded === 0) {
            window.$scrollEventJSChannelName.postMessage('${HtmlEventAction.scrollLeftEndAction}');
          }
        }                       
      }
      
      xDown = null;
      yDown = null;                                             
    }
  ''';

  static const tooltipLinkCss = '''
    .$nameClassToolTip .tooltiptext {
      visibility: hidden;
      max-width: 400px;
      background-color: black;
      color: #fff;
      text-align: center;
      border-radius: 6px;
      padding: 5px 8px 5px 8px;
      white-space: nowrap; 
      overflow: hidden;
      text-overflow: ellipsis;
      position: absolute;
      z-index: 1;
    }
    .$nameClassToolTip:hover .tooltiptext {
      visibility: visible;
    }
  ''';
}