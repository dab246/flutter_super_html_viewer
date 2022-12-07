class HtmlUtils {
  static const scrollEventJSChannelName = 'ScrollEventListener';

  static String generateHtmlDocument(
    String content, {
    double? minHeight,
    double? minWidth,
    String? customStyleCssTag,
    String? customScriptsTag,
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
          -ms-overflow-style: none;  /* IE and Edge */
          scrollbar-width: none;  /* Firefox */
        }
        
        .tmail-content::-webkit-scrollbar {
          display: none;
        }
        
        .tmail-tooltip .tooltiptext {
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
        
        .tmail-tooltip:hover .tooltiptext {
          visibility: visible;
        }
        
        pre {
          display: block;
          padding: 10px;
          margin: 0 0 10px;
          font-size: 13px;
          line-height: 1.5;
          color: #333;
          word-break: break-all;
          word-wrap: break-word;
          background-color: #f5f5f5;
          border: 1px solid #ccc;
          border-radius: 4px;
          overflow: auto;
        }
        
        blockquote {
          margin-left: 4px;
          margin-right: 4px;
          padding-left: 8px;
          padding-right: 8px;
          border-left: 2px solid #eee;
        }
        ${customStyleCssTag ?? ''}
      </style>
      ${customScriptsTag ?? ''}
      </head>
      <body>
      <div class="tmail-content">$content</div>
      </body>
      </html> 
    ''';
  }
}
