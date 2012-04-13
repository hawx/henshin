SyntaxHighlighter.config.tagName = "code";
SyntaxHighlighter.defaults['gutter'] = false;
SyntaxHighlighter.defaults['toolbar'] = false;

SyntaxHighlighter.autoloader(
    'ruby                   http://alexgorbatchev.com/pub/sh/current/scripts/shBrushRuby.js',
    'js jscript javascript  http://alexgorbatchev.com/pub/sh/current/scripts/shBrushJScript.js',
    'applescript            http://alexgorbatchev.com/pub/sh/current/scripts/shBrushAppleScript.js'
);

SyntaxHighlighter.all();
