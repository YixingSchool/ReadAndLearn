

Log4j – Log4j 2 Layouts - Apache Log4j 2 http://logging.apache.org/log4j/2.x/manual/layouts.html#JSONLayout

Layouts
An Appender uses a Layout to format a LogEvent into a form that meets the needs of whatever will be consuming the log event. In Log4j 1.x and Logback Layouts were expected to transform an event into a String. In Log4j 2 Layouts return a byte array. This allows the result of the Layout to be useful in many more types of Appenders. However, this means you need to configure most Layouts with a Charset to ensure the byte array contains correct values.

The root class for layouts that use a Charset is org.apache.logging.log4j.core.layout.AbstractStringLayout where the default is UTF-8. Each layout that extends AbstractStringLayout can provide its own default. See each layout below.

A custom character encoder was added to Log4j 2.4.1 for the ISO-8859-1 and US-ASCII charsets, to bring some of the performance improvements built-in to Java 8 to Log4j for use on Java 7. For applications that log only ISO-8859-1 characters, specifying this charset will improve performance significantly.

CSV Layouts
This layout creates Comma Separated Value (CSV) records and requires Apache Commons CSV 1.4.

The CSV layout can be used in two ways: First, using CsvParameterLayout to log event parameters to create a custom database, usually to a logger and file appender uniquely configured for this purpose. Second, using CsvLogEventLayout to log events to create a database, as an alternative to using a full DBMS or using a JDBC driver that supports the CSV format.

The CsvParameterLayout converts an event's parameters into a CSV record, ignoring the message. To log CSV records, you can use the usual Logger methods info(), debug(), and so on:

logger.info("Ignored", value1, value2, value3);
Which will create the CSV record:

value1, value2, value3
Alternatively, you can use a ObjectArrayMessage, which only carries parameters:

logger.info(new ObjectArrayMessage(value1, value2, value3));
The layouts CsvParameterLayout and CsvLogEventLayout are configured with the following parameters:

CsvParameterLayout and CsvLogEventLayout
Parameter Name	Type	Description
format	String	One of the predefined formats: Default, Excel, MySQL, RFC4180, TDF. See CSVFormat.Predefined.
delimiter	Character	Sets the delimiter of the format to the specified character.
escape	Character	Sets the escape character of the format to the specified character.
quote	Character	Sets the quoteChar of the format to the specified character.
quoteMode	String	Sets the output quote policy of the format to the specified value. One of: ALL, MINIMAL, NON_NUMERIC, NONE.
nullString	String	Writes null as the given nullString when writing records.
recordSeparator	String	Sets the record separator of the format to the specified String.
charset	Charset	The output Charset.
header	Sets the header to include when the stream is opened.	Desc.
footer	Sets the footer to include when the stream is closed.	Desc.
Logging as a CSV events looks like this:

logger.debug("one={}, two={}, three={}", 1, 2, 3);
Produces a CSV record with the following fields:

Time Nanos
Time Millis
Level
Thread ID
Thread Name
Thread Priority
Formatted Message
Logger FQCN
Logger Name
Marker
Thrown Proxy
Source
Context Map
Context Stack
0,1441617184044,DEBUG,main,"one=1, two=2, three=3",org.apache.logging.log4j.spi.AbstractLogger,,,,org.apache.logging.log4j.core.layout.CsvLogEventLayoutTest.testLayout(CsvLogEventLayoutTest.java:98),{},[]
Additional runtime dependencies are required for using CSV layouts.

GELF Layout
Lays out events in the Graylog Extended Log Format (GELF) 1.1.

This layout compresses JSON to GZIP or ZLIB (the compressionType) if log event data is larger than 1024 bytes (the compressionThreshold). This layout does not implement chunking.

Configure as follows to send to a Graylog 2.x server with UDP:

  <Appenders>
    <Socket name="Graylog" protocol="udp" host="graylog.domain.com" port="12201">
        <GelfLayout host="someserver" compressionType="ZLIB" compressionThreshold="1024"/>
    </Socket>
  </Appenders>
Configure as follows to send to a Graylog 2.x server with TCP:

  <Appenders>
    <Socket name="Graylog" protocol="tcp" host="graylog.domain.com" port="12201">
        <GelfLayout host="someserver" compressionType="OFF" includeNullDelimiter="true"/>
    </Socket>
  </Appenders>
GelfLayout Parameters
Parameter Name	Type	Description
host	String	The value of the host property (optional, defaults to local host name).
compressionType	GZIP, ZLIB or OFF	Compression to use (optional, defaults to GZIP)
compressionThreshold	int	Compress if data is larger than this number of bytes (optional, defaults to 1024)
includeStacktrace	boolean	Whether to include full stacktrace of logged Throwables (optional, default to true). If set to false, only the class name and message of the Throwable will be included.
includeThreadContext	boolean	Whether to include thread context as additional fields (optional, default to true).
includeNullDelimiter	boolean	Whether to include NULL byte as delimiter after each event (optional, default to false). Useful for Graylog GELF TCP input. Cannot be used with compression.
To include any custom field in the output, use following syntax:

  <GelfLayout>
    <KeyValuePair key="additionalField1" value="constant value"/>
    <KeyValuePair key="additionalField2" value="$${ctx:key}"/>
  </GelfLayout>
Custom fields are included in the order they are declared. The values support lookups.

See also:

The GELF specification
HTML Layout
The HtmlLayout generates an HTML page and adds each LogEvent to a row in a table.

HtmlLayout Parameters
Parameter Name	Type	Description
charset	String	The character set to use when converting the HTML String to a byte array. The value must be a valid Charset. If not specified, this layout uses UTF-8.
contentType	String	The value to assign to the Content-Type header. The default is "text/html".
locationInfo	boolean	
If true, the filename and line number will be included in the HTML output. The default value is false.

Generating location information is an expensive operation and may impact performance. Use with caution.

title	String	A String that will appear as the HTML title.
fontName	String	The font-family to use. The default is "arial,sans-serif".
fontSize	String	The font-size to use. The default is "small".
JSON Layout
Appends a series of JSON events as strings serialized as bytes.

Complete well-formed JSON vs. fragment JSON

If you configure complete="true", the appender outputs a well-formed JSON document. By default, with complete="false", you should include the output as an external file in a separate file to form a well-formed JSON document.

If complete="false", the appender does not write the JSON open array character "[" at the start of the document, "]" and the end, nor comma "," between records.

Log event follows this pattern:

{
  "timeMillis" : 1493121664118,
  "thread" : "main",
  "level" : "INFO",
  "loggerName" : "HelloWorld",
  "marker" : {
    "name" : "child",
    "parents" : [ {
      "name" : "parent",
      "parents" : [ {
        "name" : "grandparent"
      } ]
    } ]
  },
  "message" : "Hello, world!",
  "thrown" : {
    "commonElementCount" : 0,
    "message" : "error message",
    "name" : "java.lang.RuntimeException",
    "extendedStackTrace" : [ {
      "class" : "logtest.Main",
      "method" : "main",
      "file" : "Main.java",
      "line" : 29,
      "exact" : true,
      "location" : "classes/",
      "version" : "?"
    } ]
  },
  "contextStack" : [ "one", "two" ],
  "endOfBatch" : false,
  "loggerFqcn" : "org.apache.logging.log4j.spi.AbstractLogger",
  "contextMap" : {
    "bar" : "BAR",
    "foo" : "FOO"
  },
  "threadId" : 1,
  "threadPriority" : 5,
  "source" : {
    "class" : "logtest.Main",
    "method" : "main",
    "file" : "Main.java",
    "line" : 29
  }
}
If complete="false", the appender does not write the JSON open array character "[" at the start of the document, "]" and the end, nor comma "," between records.

Pretty vs. compact JSON

By default, the JSON layout is not compact (a.k.a. not "pretty") with compact="false", which means the appender uses end-of-line characters and indents lines to format the text. If compact="true", then no end-of-line or indentation is used. Message content may contain, of course, escaped end-of-lines.

JsonLayout Parameters
Parameter Name	Type	Description
charset	String	The character set to use when converting to a byte array. The value must be a valid Charset. If not specified, UTF-8 will be used.
compact	boolean	If true, the appender does not use end-of-lines and indentation. Defaults to false.
eventEol	boolean	If true, the appender appends an end-of-line after each record. Defaults to false. Use with eventEol=true and compact=true to get one record per line.
complete	boolean	If true, the appender includes the JSON header and footer, and comma between records. Defaults to false.
properties	boolean	If true, the appender includes the thread context map in the generated JSON. Defaults to false.
propertiesAsList	boolean	If true, the thread context map is included as a list of map entry objects, where each entry has a "key" attribute (whose value is the key) and a "value" attribute (whose value is the value). Defaults to false, in which case the thread context map is included as a simple map of key-value pairs.
locationInfo	boolean	
If true, the appender includes the location information in the generated JSON. Defaults to false.

Generating location information is an expensive operation and may impact performance. Use with caution.

includeStacktrace	boolean	If true, include full stacktrace of any logged Throwable (optional, default to true).
stacktraceAsString	boolean	Whether to format the stacktrace as a string, and not a nested object (optional, defaults to false).
includeNullDelimiter	boolean	Whether to include NULL byte as delimiter after each event (optional, default to false).
To include any custom field in the output, use following syntax:

  <JsonLayout>
    <KeyValuePair key="additionalField1" value="constant value"/>
    <KeyValuePair key="additionalField2" value="$${ctx:key}"/>
  </JsonLayout>
Custom fields are always last, in the order they are declared. The values support lookups.

Additional runtime dependencies are required for using JsonLayout.

Pattern Layout
A flexible layout configurable with pattern string. The goal of this class is to format a LogEvent and return the results. The format of the result depends on the conversion pattern.

The conversion pattern is closely related to the conversion pattern of the printf function in C. A conversion pattern is composed of literal text and format control expressions called conversion specifiers.

Note that any literal text, including Special Characters, may be included in the conversion pattern. Special Characters include \t, \n, \r, \f. Use \\ to insert a single backslash into the output.

Each conversion specifier starts with a percent sign (%) and is followed by optional format modifiers and a conversion character. The conversion character specifies the type of data, e.g. category, priority, date, thread name. The format modifiers control such things as field width, padding, left and right justification. The following is a simple example.

Let the conversion pattern be "%-5p [%t]: %m%n" and assume that the Log4j environment was set to use a PatternLayout. Then the statements

Logger logger = LogManager.getLogger("MyLogger");
logger.debug("Message 1");
logger.warn("Message 2");
would yield the output
DEBUG [main]: Message 1
WARN  [main]: Message 2
Note that there is no explicit separator between text and conversion specifiers. The pattern parser knows when it has reached the end of a conversion specifier when it reads a conversion character. In the example above the conversion specifier %-5p means the priority of the logging event should be left justified to a width of five characters.

If the pattern string does not contain a specifier to handle a Throwable being logged, parsing of the pattern will act as if the "%xEx" specifier had be added to the end of the string. To suppress formatting of the Throwable completely simply add "%ex{0}" as a specifier in the pattern string.

PatternLayout Parameters
Parameter Name	Type	Description
charset	String	The character set to use when converting the syslog String to a byte array. The String must be a valid Charset. If not specified, this layout uses the platform default character set.
pattern	String	A composite pattern string of one or more conversion patterns from the table below. Cannot be specified with a PatternSelector.
patternSelector	PatternSelector	A component that analyzes information in the LogEvent and determines which pattern should be used to format the event. The pattern and patternSelector parameters are mutually exclusive.
replace	RegexReplacement	Allows portions of the resulting String to be replaced. If configured, the replace element must specify the regular expression to match and the substitution. This performs a function similar to the RegexReplacement converter but applies to the whole message while the converter only applies to the String its pattern generates.
alwaysWriteExceptions	boolean	If true (it is by default) exceptions are always written even if the pattern contains no exception conversions. This means that if you do not include a way to output exceptions in your pattern, the default exception formatter will be added to the end of the pattern. Setting this to false disables this behavior and allows you to exclude exceptions from your pattern output.
header	String	The optional header string to include at the top of each log file.
footer	String	The optional footer string to include at the bottom of each log file.
disableAnsi	boolean	If true (default is false), do not output ANSI escape codes.
noConsoleNoAnsi	boolean	If true (default is false) and System.console() is null, do not output ANSI escape codes.
RegexReplacement Parameters
Parameter Name	Type	Description
regex	String	A Java-compliant regular expression to match in the resulting string. See Pattern .
replacement	String	The string to replace any matched sub-strings with.
Patterns

The conversions that are provided with Log4j are:

Conversion Pattern	Description
c{precision}
logger{precision}	
Outputs the name of the logger that published the logging event. The logger conversion specifier can be optionally followed by precision specifier, which consists of a decimal integer, or a pattern starting with a decimal integer.

When the precision specifier is an integer value, it reduces the size of the logger name. If the number is positive, the layout prints the corresponding number of rightmost logger name components. If negative, the layout removes the corresponding number of leftmost logger name components.

If the precision contains any non-integer characters, then the layout abbreviates the name based on the pattern. If the precision integer is less than one, the layout still prints the right-most token in full. By default, the layout prints the logger name in full.

Conversion Pattern	Logger Name	Result
%c{1}	org.apache.commons.Foo	Foo
%c{2}	org.apache.commons.Foo	commons.Foo
%c{10}	org.apache.commons.Foo	org.apache.commons.Foo
%c{-1}	org.apache.commons.Foo	apache.commons.Foo
%c{-2}	org.apache.commons.Foo	commons.Foo
%c{-10}	org.apache.commons.Foo	org.apache.commons.Foo
%c{1.}	org.apache.commons.Foo	o.a.c.Foo
%c{1.1.~.~}	org.apache.commons.test.Foo	o.a.~.~.Foo
%c{.}	org.apache.commons.test.Foo	....Foo
C{precision}
class{precision}	
Outputs the fully qualified class name of the caller issuing the logging request. This conversion specifier can be optionally followed by precision specifier, that follows the same rules as the logger name converter.

Generating the class name of the caller (location information) is an expensive operation and may impact performance. Use with caution.

d{pattern}
date{pattern}	
Outputs the date of the logging event. The date conversion specifier may be followed by a set of braces containing a date and time pattern string per SimpleDateFormat .

The predefined formats are DEFAULT, ABSOLUTE, COMPACT, DATE, ISO8601, and ISO8601_BASIC.

You can also use a set of braces containing a time zone id per java.util.TimeZone.getTimeZone. If no date format specifier is given then the DEFAULT format is used.

Pattern	Example
%d{DEFAULT}	2012-11-02 14:34:02,781
%d{ISO8601}	2012-11-02T14:34:02,781
%d{ISO8601_BASIC}	20121102T143402,781
%d{ABSOLUTE}	14:34:02,781
%d{DATE}	02 Nov 2012 14:34:02,781
%d{COMPACT}	20121102143402781
%d{HH:mm:ss,SSS}	14:34:02,781
%d{dd MMM yyyy HH:mm:ss,SSS}	02 Nov 2012 14:34:02,781
%d{HH:mm:ss}{GMT+0}	18:34:02
%d{UNIX}	1351866842
%d{UNIX_MILLIS}	1351866842781
%d{UNIX} outputs the UNIX time in seconds. %d{UNIX_MILLIS} outputs the UNIX time in milliseconds. The UNIX time is the difference, in seconds for UNIX and in milliseconds for UNIX_MILLIS, between the current time and midnight, January 1, 1970 UTC. While the time unit is milliseconds, the granularity depends on the operating system (Windows). This is an efficient way to output the event time because only a conversion from long to String takes place, there is no Date formatting involved.

enc{pattern}{[HTML|XML|JSON|CRLF]}
encode{pattern}{[HTML|XML|JSON|CRLF]}	
Encodes and escapes special characters suitable for output in specific markup languages. By default, this encodes for HTML if only one option is specified. The second option is used to specify which encoding format should be used. This converter is particularly useful for encoding user provided data so that the output data is not written improperly or insecurely.

A typical usage would encode the message %enc{%m} but user input could come from other locations as well, such as the MDC %enc{%mdc{key}}

Using the HTML encoding format, the following characters are replaced:

Character	Replacement
'\r', '\n'	Converted into escaped strings "\\r" and "\\n" respectively
&, <, >, ", ', /	Replaced with the corresponding HTML entity
Using the XML encoding format, this follows the escaping rules specified by the XML specification:

Character	Replacement
&, <, >, ", '	Replaced with the corresponding XML entity
Using the JSON encoding format, this follows the escaping rules specified by RFC 4627 section 2.5:

Character	Replacement
U+0000 - U+001F	\u0000 - \u001F
Any other control characters	Encoded into its \uABCD equivalent escaped code point
"	\"
\	\\
For example, the pattern {"message": "%enc{%m}{JSON}"} could be used to output a valid JSON document containing the log message as a string value.

Using the CRLF encoding format, the following characters are replaced:

Character	Replacement
'\r', '\n'	Converted into escaped strings "\\r" and "\\n" respectively
equals{pattern}{test}{substitution}
equalsIgnoreCase{pattern}{test}{substitution}	
Replaces occurrences of 'test', a string, with its replacement 'substitution' in the string resulting from evaluation of the pattern. For example, "%equals{[%marker]}{[]}{}" will replace '[]' strings produces by events without markers with an empty string.

The pattern can be arbitrarily complex and in particular can contain multiple conversion keywords.

ex|exception|throwable
{
  [ "none"
   | "full"
   | depth
   | "short"
   | "short.className"
   | "short.fileName"
   | "short.lineNumber"
   | "short.methodName"
   | "short.message"
   | "short.localizedMessage"]}
  [,filters(package,package,...)]
  [,separator(separator)]
}
{suffix(pattern)
}
Outputs the Throwable trace bound to the logging event, by default this will output the full trace as one would normally find with a call to Throwable.printStackTrace().

You can follow the throwable conversion word with an option in the form %throwable{option}.

%throwable{short} outputs the first line of the Throwable.

%throwable{short.className} outputs the name of the class where the exception occurred.

%throwable{short.methodName} outputs the method name where the exception occurred.

%throwable{short.fileName} outputs the name of the class where the exception occurred.

%throwable{short.lineNumber} outputs the line number where the exception occurred.

%throwable{short.message} outputs the message.

%throwable{short.localizedMessage} outputs the localized message.

%throwable{n} outputs the first n lines of the stack trace.

Specifying %throwable{none} or %throwable{0} suppresses output of the exception.

Use filters(packages) where packages is a list of package names to suppress matching stack frames from stack traces.

Use a separator string to separate the lines of a stack trace. For example: separator(|). The default value is the line.separator system property, which is operating system dependent.

Use ex{suffix(pattern) to add the output of pattern to the output only when there is a throwable to print.

F
file	
Outputs the file name where the logging request was issued.

Generating the file information (location information) is an expensive operation and may impact performance. Use with caution.

highlight{pattern}{style}	
Adds ANSI colors to the result of the enclosed pattern based on the current event's logging level. (See Jansi configuration.)

The default colors for each level are:

Level	ANSI color
FATAL	Bright red
ERROR	Bright red
WARN	Yellow
INFO	Green
DEBUG	Cyan
TRACE	Black (looks dark grey)
The color names are ANSI names defined in the AnsiEscape class.

The color and attribute names and are standard, but the exact shade, hue, or value.

Color table
Intensity Code	0	1	2	3	4	5	6	7
Normal	Black	Red	Green	Yellow	Blue	Magenta	Cyan	White
Bright	Black	Red	Green	Yellow	Blue	Magenta	Cyan	White
You can use the default colors with:

%highlight{%d [%t] %-5level: %msg%n%throwable}
You can override the default colors in the optional {style} option. For example:

%highlight{%d [%t] %-5level: %msg%n%throwable}{FATAL=white, ERROR=red, WARN=blue, INFO=black, DEBUG=green, TRACE=blue}
You can highlight only the a portion of the log event:

%d [%t] %highlight{%-5level: %msg%n%throwable}
You can style one part of the message and highlight the rest the log event:

%style{%d [%t]}{black} %highlight{%-5level: %msg%n%throwable}
You can also use the STYLE key to use a predefined group of colors:

%highlight{%d [%t] %-5level: %msg%n%throwable}{STYLE=Logback}
The STYLE value can be one of:
Style	Description
Default	See above
Logback	
Level	ANSI color
FATAL	Blinking bright red
ERROR	Bright red
WARN	Red
INFO	Blue
DEBUG	Normal
TRACE	Normal
K{key}
map{key}
MAP{key}	
Outputs the entries in a MapMessage, if one is present in the event. The K conversion character can be followed by the key for the map placed between braces, as in %K{clientNumber} where clientNumber is the key. The value in the Map corresponding to the key will be output. If no additional sub-option is specified, then the entire contents of the Map key value pair set is output using a format {{key1,val1},{key2,val2}}

l
location	
Outputs location information of the caller which generated the logging event.

The location information depends on the JVM implementation but usually consists of the fully qualified name of the calling method followed by the callers source the file name and line number between parentheses.

Generating location information is an expensive operation and may impact performance. Use with caution.

L
line	
Outputs the line number from where the logging request was issued.

Generating line number information (location information) is an expensive operation and may impact performance. Use with caution.

m{nolookups}{ansi}
msg{nolookups}{ansi}
message{nolookups}{ansi}	
Outputs the application supplied message associated with the logging event.

Add {ansi} to render messages with ANSI escape codes (requires JAnsi, see configuration.)

The default syntax for embedded ANSI codes is:

@|code(,code)* text|@
For example, to render the message "Hello" in green, use:

@|green Hello|@
To render the message "Hello" in bold and red, use:

@|bold,red Warning!|@
You can also define custom style names in the configuration with the syntax:

%message{ansi}{StyleName=value(,value)*( StyleName=value(,value)*)*}%n
For example:

%message{ansi}{WarningStyle=red,bold KeyStyle=white ValueStyle=blue}%n
The call site can look like this:

logger.info("@|KeyStyle {}|@ = @|ValueStyle {}|@", entry.getKey(), entry.getValue());
Use {nolookups} to log messages like "${date:YYYY-MM-dd}" without using any lookups. Normally calling logger.info("Try ${date:YYYY-MM-dd}") would replace the date template ${date:YYYY-MM-dd} with an actual date. Using nolookups disables this feature and logs the message string untouched.

M
method	
Outputs the method name where the logging request was issued.

Generating the method name of the caller (location information) is an expensive operation and may impact performance. Use with caution.

marker	The full name of the marker, including parents, if one is present.
markerSimpleName	The simple name of the marker (not including parents), if one is present.
maxLen
maxLength	
Outputs the result of evaluating the pattern and truncating the result. If the length is greater than 20, then the output will contain a trailing ellipsis. If the provided length is invalid, a default value of 100 is used.

Example syntax: %maxLen{%p: %c{1} - %m%notEmpty{ =>%ex{short}}}{160} will be limited to 160 characters with a trailing ellipsis. Another example: %maxLen{%m}{20} will be limited to 20 characters and no trailing ellipsis.

n	
Outputs the platform dependent line separator character or characters.

This conversion character offers practically the same performance as using non-portable line separator strings such as "\n", or "\r\n". Thus, it is the preferred way of specifying a line separator.

N
nano	
Outputs the result of System.nanoTime() at the time the log event was created.

pid{[defaultValue]}
processId{[defaultValue]}	
Outputs the process ID if supported by the underlying platform. An optional default value may be specified to be shown if the platform does not support process IDs.

variablesNotEmpty{pattern}
varsNotEmpty{pattern}
notEmpty{pattern}	
Outputs the result of evaluating the pattern if and only if all variables in the pattern are not empty.

For example:

%notEmpty{[%marker]}
p|level{level=label, level=label, ...} p|level{length=n} p|level{lowerCase=true|false}	
Outputs the level of the logging event. You provide a level name map in the form "level=value, level=value" where level is the name of the Level and value is the value that should be displayed instead of the name of the Level.

For example:

%level{WARN=Warning, DEBUG=Debug, ERROR=Error, TRACE=Trace, INFO=Info}
Alternatively, for the compact-minded:

%level{WARN=W, DEBUG=D, ERROR=E, TRACE=T, INFO=I}
More succinctly, for the same result as above, you can define the length of the level label:

%level{length=1}
If the length is greater than a level name length, the layout uses the normal level name.
You can combine the two kinds of options:

%level{ERROR=Error, length=2}
This give you the Error level name and all other level names of length 2.
Finally, you can output lower-case level names (the default is upper-case):

%level{lowerCase=true}
r
relative	Outputs the number of milliseconds elapsed since the JVM was started until the creation of the logging event.
replace{pattern}{regex}{substitution}	
Replaces occurrences of 'regex', a regular expression, with its replacement 'substitution' in the string resulting from evaluation of the pattern. For example, "%replace{%msg}{\s}{}" will remove all spaces contained in the event message.

The pattern can be arbitrarily complex and in particular can contain multiple conversion keywords. For instance, "%replace{%logger %msg}{\.}{/}" will replace all dots in the logger or the message of the event with a forward slash.

rEx|rException|rThrowable
  {
    ["none" | "short" | "full" | depth]
    [,filters(package,package,...)]
    [,separator(separator)]
  }
  {ansi(
    Key=Value,Value,...
    Key=Value,Value,...
    ...)
  }
  {suffix(pattern)}
The same as the %throwable conversion word but the stack trace is printed starting with the first exception that was thrown followed by each subsequent wrapping exception.

The throwable conversion word can be followed by an option in the form %rEx{short} which will only output the first line of the Throwable or %rEx{n} where the first n lines of the stack trace will be printed.

Specifying %rEx{none} or %rEx{0} will suppress printing of the exception.

Use filters(packages) where packages is a list of package names to suppress matching stack frames from stack traces.

Use a separator string to separate the lines of a stack trace. For example: separator(|). The default value is the line.separator system property, which is operating system dependent.

Use rEx{suffix(pattern) to add the output of pattern to the output only when there is a throwable to print.

sn
sequenceNumber	Includes a sequence number that will be incremented in every event. The counter is a static variable so will only be unique within applications that share the same converter Class object.
style{pattern}{ANSI style}	
Uses ANSI escape sequences to style the result of the enclosed pattern. The style can consist of a comma separated list of style names from the following table. (See Jansi configuration.)

Style Name	Description
Normal	Normal display
Bright	Bold
Dim	Dimmed or faint characters
Underline	Underlined characters
Blink	Blinking characters
Reverse	Reverse video
Hidden	
Black or FG_Black	Set foreground color to black
Red or FG_Red	Set foreground color to red
Green or FG_Green	Set foreground color to green
Yellow or FG_Yellow	Set foreground color to yellow
Blue or FG_Blue	Set foreground color to blue
Magenta or FG_Magenta	Set foreground color to magenta
Cyan or FG_Cyan	Set foreground color to cyan
White or FG_White	Set foreground color to white
Default or FG_Default	Set foreground color to default (white)
BG_Black	Set background color to black
BG_Red	Set background color to red
BG_Green	Set background color to green
BG_Yellow	Set background color to yellow
BG_Blue	Set background color to blue
BG_Magenta	Set background color to magenta
BG_Cyan	Set background color to cyan
BG_White	Set background color to white
For example:

%style{%d{ISO8601}}{black} %style{[%t]}{blue} %style{%-5level:}{yellow} %style{%msg%n%throwable}{green}
You can also combine styles:

%d %highlight{%p} %style{%logger}{bright,cyan} %C{1.} %msg%n
You can also use % with a color like %black, %blue, %cyan, and so on. For example:

%black{%d{ISO8601}} %blue{[%t]} %yellow{%-5level:} %green{%msg%n%throwable}
T
tid
threadId	Outputs the ID of the thread that generated the logging event.
t
tn
thread
threadName	Outputs the name of the thread that generated the logging event.
tp
threadPriority	Outputs the priority of the thread that generated the logging event.
x
NDC	Outputs the Thread Context Stack (also known as the Nested Diagnostic Context or NDC) associated with the thread that generated the logging event.
X{key[,key2...]}
mdc{key[,key2...]}
MDC{key[,key2...]}	
Outputs the Thread Context Map (also known as the Mapped Diagnostic Context or MDC) associated with the thread that generated the logging event. The X conversion character can be followed by one or more keys for the map placed between braces, as in %X{clientNumber} where clientNumber is the key. The value in the MDC corresponding to the key will be output.

If a list of keys are provided, such as %X{name, number}, then each key that is present in the ThreadContext will be output using the format {name=val1, number=val2}. The key/value pairs will be printed in the order they appear in the list.

If no sub-options are specified then the entire contents of the MDC key value pair set is output using a format {key1=val1, key2=val2}. The key/value pairs will be printed in sorted order.

See the ThreadContext class for more details.

u{"RANDOM" | "TIME"}
uuid	Includes either a random or a time-based UUID. The time-based UUID is a Type 1 UUID that can generate up to 10,000 unique ids per millisecond, will use the MAC address of each host, and to try to insure uniqueness across multiple JVMs and/or ClassLoaders on the same host a random number between 0 and 16,384 will be associated with each instance of the UUID generator Class and included in each time-based UUID generated. Because time-based UUIDs contain the MAC address and timestamp they should be used with care as they can cause a security vulnerability.
xEx|xException|xThrowable
  {
    ["none" | "short" | "full" | depth]
    [,filters(package,package,...)]
    [,separator(separator)]
  }
  {ansi(
    Key=Value,Value,...
    Key=Value,Value,...
    ...)
  }
  {suffix(pattern)}
The same as the %throwable conversion word but also includes class packaging information.

At the end of each stack element of the exception, a string containing the name of the jar file that contains the class or the directory the class is located in and the "Implementation-Version" as found in that jar's manifest will be added. If the information is uncertain, then the class packaging data will be preceded by a tilde, i.e. the '~' character.

The throwable conversion word can be followed by an option in the form %xEx{short} which will only output the first line of the Throwable or %xEx{n} where the first n lines of the stack trace will be printed. Specifying %xEx{none} or %xEx{0} will suppress printing of the exception.

Use filters(packages) where packages is a list of package names to suppress matching stack frames from stack traces.

Use a separator string to separate the lines of a stack trace. For example: separator(|). The default value is the line.separator system property, which is operating system dependent.

The ansi option renders stack traces with ANSI escapes code using the JAnsi library. (See configuration.) Use {ansi} to use the default color mapping. You can specify your own mappings with key=value pairs. The keys are:

Prefix
Name
NameMessageSeparator
Message
At
CauseLabel
Text
More
Suppressed
StackTraceElement.ClassName
StackTraceElement.ClassMethodSeparator
StackTraceElement.MethodName
StackTraceElement.NativeMethod
StackTraceElement.FileName
StackTraceElement.LineNumber
StackTraceElement.Container
StackTraceElement.ContainerSeparator
StackTraceElement.UnknownSource
ExtraClassInfo.Inexact
ExtraClassInfo.Container
ExtraClassInfo.ContainerSeparator
ExtraClassInfo.Location
ExtraClassInfo.Version
The values are names from JAnsi's Code class like blue, bg_red, and so on (Log4j ignores case.)

The special key StyleMapName can be set to one of the following predefined maps: Spock, Kirk.

As with %throwable, the %xEx{suffix(pattern) conversion will add the output of pattern to the output only if there is a throwable to print.

%	The sequence %% outputs a single percent sign.
By default the relevant information is output as is. However, with the aid of format modifiers it is possible to change the minimum field width, the maximum field width and justification.

The optional format modifier is placed between the percent sign and the conversion character.

The first optional format modifier is the left justification flag which is just the minus (-) character. Then comes the optional minimum field width modifier. This is a decimal constant that represents the minimum number of characters to output. If the data item requires fewer characters, it is padded on either the left or the right until the minimum width is reached. The default is to pad on the left (right justify) but you can specify right padding with the left justification flag. The padding character is space. If the data item is larger than the minimum field width, the field is expanded to accommodate the data. The value is never truncated.

This behavior can be changed using the maximum field width modifier which is designated by a period followed by a decimal constant. If the data item is longer than the maximum field, then the extra characters are removed from the beginning of the data item and not from the end. For example, it the maximum field width is eight and the data item is ten characters long, then the first two characters of the data item are dropped. This behavior deviates from the printf function in C where truncation is done from the end.

Truncation from the end is possible by appending a minus character right after the period. In that case, if the maximum field width is eight and the data item is ten characters long, then the last two characters of the data item are dropped.

Below are various format modifier examples for the category conversion specifier.

Pattern Converters
Format modifier	left justify	minimum width	maximum width	comment
%20c	false	20	none	Left pad with spaces if the category name is less than 20 characters long.
%-20c	true	20	none	Right pad with spaces if the category name is less than 20 characters long.
%.30c	NA	none	30	Truncate from the beginning if the category name is longer than 30 characters.
%20.30c	false	20	30	Left pad with spaces if the category name is shorter than 20 characters. However, if category name is longer than 30 characters, then truncate from the beginning.
%-20.30c	true	20	30	Right pad with spaces if the category name is shorter than 20 characters. However, if category name is longer than 30 characters, then truncate from the beginning.
%-20.-30c	true	20	30	Right pad with spaces if the category name is shorter than 20 characters. However, if category name is longer than 30 characters, then truncate from the end.
ANSI Styling on Windows

ANSI escape sequences are supported natively on many platforms but are not by default on Windows. To enable ANSI support add the Jansi jar to your application and set property log4j.skipJansi to false. This allows Log4j to use Jansi to add ANSI escape codes when writing to the console.

NOTE: Prior to Log4j 2.10, Jansi was enabled by default. The fact that Jansi requires native code means that Jansi can only be loaded by a single class loader. For web applications this means the Jansi jar has to be in the web container's classpath. To avoid causing problems for web applications, Log4j will no longer automatically try to load Jansi without explicit configuration from Log4j 2.10 onward.

Example Patterns

Filtered Throwables

This example shows how to filter out classes from unimportant packages in stack traces.

<properties>
  <property name="filters">org.junit,org.apache.maven,sun.reflect,java.lang.reflect</property>
</properties>
...
<PatternLayout pattern="%m%xEx{filters(${filters})}%n"/>
The result printed to the console will appear similar to:

Exception java.lang.IllegalArgumentException: IllegalArgument
at org.apache.logging.log4j.core.pattern.ExtendedThrowableTest.testException(ExtendedThrowableTest.java:72) [test-classes/:?]
... suppressed 26 lines
at $Proxy0.invoke(Unknown Source)} [?:?]
... suppressed 3 lines
Caused by: java.lang.NullPointerException: null pointer
at org.apache.logging.log4j.core.pattern.ExtendedThrowableTest.testException(ExtendedThrowableTest.java:71) ~[test-classes/:?]
... 30 more
ANSI Styled

The log level will be highlighted according to the event's log level. All the content that follows the level will be bright green.

<PatternLayout>
  <pattern>%d %highlight{%p} %style{%C{1.} [%t] %m}{bold,green}%n</pattern>
</PatternLayout>
Pattern Selectors

The PatternLayout can be configured with a PatternSelector to allow it to choose a pattern to use based on attributes of the log event or other factors. A PatternSelector will normally be configured with a defaultPattern attribute, which is used when other criteria don't match, and a set of PatternMatch elements that identify the various patterns that can be selected.

MarkerPatternSelector

The MarkerPatternSelector selects patterns based on the Marker included in the log event. If the Marker in the log event is equal to or is an ancestor of the name specified on the PatternMatch key attribute, then the pattern specified on that PatternMatch element will be used.

<PatternLayout>
  <MarkerPatternSelector defaultPattern="[%-5level] %c{1.} %msg%n">
    <PatternMatch key="FLOW" pattern="[%-5level] %c{1.} ====== %C{1.}.%M:%L %msg ======%n"/>
  </MarkerPatternSelector>
</PatternLayout>
ScriptPatternSelector

The ScriptPatternSelector executes a script as descibed in the Scripts section of the Configuration chapter. The script is passed all the properties configured in the Properties section of the configuration, the StrSubstitutor used by the Confguration in the "substitutor" vairables, and the log event in the "logEvent" variable, and is expected to return the value of the PatternMatch key that should be used, or null if the default pattern should be used.

<PatternLayout>
  <ScriptPatternSelector defaultPattern="[%-5level] %c{1.} %C{1.}.%M.%L %msg%n">
    <Script name="BeanShellSelector" language="bsh"><![CDATA[
      if (logEvent.getLoggerName().equals("NoLocation")) {
        return "NoLocation";
      } else if (logEvent.getMarker() != null && logEvent.getMarker().isInstanceOf("FLOW")) {
        return "Flow";
      } else {
        return null;
      }]]>
    </Script>
    <PatternMatch key="NoLocation" pattern="[%-5level] %c{1.} %msg%n"/>
    <PatternMatch key="Flow" pattern="[%-5level] %c{1.} ====== %C{1.}.%M:%L %msg ======%n"/>
  </ScriptPatternSelector>
</PatternLayout>
RFC5424 Layout
As the name implies, the Rfc5424Layout formats LogEvents in accordance with RFC 5424, the enhanced Syslog specification. Although the specification is primarily directed at sending messages via Syslog, this format is quite useful for other purposes since items are passed in the message as self-describing key/value pairs.

Rfc5424Layout Parameters
Parameter Name	Type	Description
appName	String	The value to use as the APP-NAME in the RFC 5424 syslog record.
charset	String	The character set to use when converting the syslog String to a byte array. The String must be a valid Charset. If not specified, the default system Charset will be used.
enterpriseNumber	integer	The IANA enterprise number as described in RFC 5424
exceptionPattern	String	One of the conversion specifiers from PatternLayout that defines which ThrowablePatternConverter to use to format exceptions. Any of the options that are valid for those specifiers may be included. The default is to not include the Throwable from the event, if any, in the output.
facility	String	The facility is used to try to classify the message. The facility option must be set to one of "KERN", "USER", "MAIL", "DAEMON", "AUTH", "SYSLOG", "LPR", "NEWS", "UUCP", "CRON", "AUTHPRIV", "FTP", "NTP", "AUDIT", "ALERT", "CLOCK", "LOCAL0", "LOCAL1", "LOCAL2", "LOCAL3", "LOCAL4", "LOCAL5", "LOCAL6", or "LOCAL7". These values may be specified as upper or lower case characters.
format	String	If set to "RFC5424" the data will be formatted in accordance with RFC 5424. Otherwise, it will be formatted as a BSD Syslog record. Note that although BSD Syslog records are required to be 1024 bytes or shorter the SyslogLayout does not truncate them. The RFC5424Layout also does not truncate records since the receiver must accept records of up to 2048 bytes and may accept records that are longer.
id	String	The default structured data id to use when formatting according to RFC 5424. If the LogEvent contains a StructuredDataMessage the id from the Message will be used instead of this value.
includeMDC	boolean	Indicates whether data from the ThreadContextMap will be included in the RFC 5424 Syslog record. Defaults to true.
loggerFields	List of KeyValuePairs	Allows arbitrary PatternLayout patterns to be included as specified ThreadContext fields; no default specified. To use, include a <LoggerFields> nested element, containing one or more <KeyValuePair> elements. Each <KeyValuePair> must have a key attribute, which specifies the key name which will be used to identify the field within the MDC Structured Data element, and a value attribute, which specifies the PatternLayout pattern to use as the value.
mdcExcludes	String	A comma separated list of mdc keys that should be excluded from the LogEvent. This is mutually exclusive with the mdcIncludes attribute. This attribute only applies to RFC 5424 syslog records.
mdcIncludes	String	A comma separated list of mdc keys that should be included in the FlumeEvent. Any keys in the MDC not found in the list will be excluded. This option is mutually exclusive with the mdcExcludes attribute. This attribute only applies to RFC 5424 syslog records.
mdcRequired	String	A comma separated list of mdc keys that must be present in the MDC. If a key is not present a LoggingException will be thrown. This attribute only applies to RFC 5424 syslog records.
mdcPrefix	String	A string that should be prepended to each MDC key in order to distinguish it from event attributes. The default string is "mdc:". This attribute only applies to RFC 5424 syslog records.
mdcId	String	A required MDC ID. This attribute only applies to RFC 5424 syslog records.
messageId	String	The default value to be used in the MSGID field of RFC 5424 syslog records.
newLine	boolean	If true, a newline will be appended to the end of the syslog record. The default is false.
newLineEscape	String	String that should be used to replace newlines within the message text.
Serialized Layout
The SerializedLayout simply serializes the LogEvent into a byte array using Java Serialization. The SerializedLayout accepts no parameters.

This layout is deprecated since version 2.9. Java Serialization has inherent security weaknesses, using this layout is no longer recommended. An alternative layout containing the same information is JsonLayout, configured with properties="true".

Syslog Layout
The SyslogLayout formats the LogEvent as BSD Syslog records matching the same format used by Log4j 1.2.

SyslogLayout Parameters
Parameter Name	Type	Description
charset	String	The character set to use when converting the syslog String to a byte array. The String must be a valid Charset. If not specified, this layout uses UTF-8.
facility	String	The facility is used to try to classify the message. The facility option must be set to one of "KERN", "USER", "MAIL", "DAEMON", "AUTH", "SYSLOG", "LPR", "NEWS", "UUCP", "CRON", "AUTHPRIV", "FTP", "NTP", "AUDIT", "ALERT", "CLOCK", "LOCAL0", "LOCAL1", "LOCAL2", "LOCAL3", "LOCAL4", "LOCAL5", "LOCAL6", or "LOCAL7". These values may be specified as upper or lower case characters.
newLine	boolean	If true, a newline will be appended to the end of the syslog record. The default is false.
newLineEscape	String	String that should be used to replace newlines within the message text.
XML Layout
Appends a series of Event elements as defined in the log4j.dtd.

Complete well-formed XML vs. fragment XML

If you configure complete="true", the appender outputs a well-formed XML document where the default namespace is the Log4j namespace "http://logging.apache.org/log4j/2.0/events". By default, with complete="false", you should include the output as an external entity in a separate file to form a well-formed XML document, in which case the appender uses namespacePrefix with a default of "log4j".

A well-formed XML document follows this pattern:

<Event xmlns="http://logging.apache.org/log4j/2.0/events"
       timeMillis="1493122559666"
       level="INFO"
       loggerName="HelloWorld"
       endOfBatch="false"
       thread="main"
       loggerFqcn="org.apache.logging.log4j.spi.AbstractLogger"
       threadId="1"
       threadPriority="5">
  <Marker name="child">
    <Parents>
      <Marker name="parent">
        <Parents>
          <Marker name="grandparent"/>
        </Parents>
      </Marker>
    </Parents>
  </Marker>
  <Message>Hello, world!</Message>
  <ContextMap>
    <item key="bar" value="BAR"/>
    <item key="foo" value="FOO"/>
  </ContextMap>
  <ContextStack>
    <ContextStackItem>one</ContextStackItem>
    <ContextStackItem>two</ContextStackItem>
  </ContextStack>
  <Source
      class="logtest.Main"
      method="main"
      file="Main.java"
      line="29"/>
  <Thrown commonElementCount="0" message="error message" name="java.lang.RuntimeException">
    <ExtendedStackTrace>
      <ExtendedStackTraceItem
          class="logtest.Main"
          method="main"
          file="Main.java"
          line="29"
          exact="true"
          location="classes/"
          version="?"/>
    </ExtendedStackTrace>
  </Thrown>
</Event>
If complete="false", the appender does not write the XML processing instruction and the root element.

Marker

Markers are represented by a Marker element within the Event element. The Marker element appears only when a marker is used in the log message. The name of the marker's parent will be provided in the parent attribute of the Marker element.

Pretty vs. compact XML

By default, the XML layout is not compact (a.k.a. not "pretty") with compact="false", which means the appender uses end-of-line characters and indents lines to format the XML. If compact="true", then no end-of-line or indentation is used. Message content may contain, of course, end-of-lines.

XmlLayout Parameters
Parameter Name	Type	Description
charset	String	The character set to use when converting to a byte array. The value must be a valid Charset. If not specified, UTF-8 will be used.
compact	boolean	If true, the appender does not use end-of-lines and indentation. Defaults to false.
complete	boolean	If true, the appender includes the XML header and footer. Defaults to false.
properties	boolean	If true, the appender includes the thread context map in the generated XML. Defaults to false.
locationInfo	boolean	
If true, the appender includes the location information in the generated XML. Defaults to false.

Generating location information is an expensive operation and may impact performance. Use with caution.

includeStacktrace	boolean	If true, include full stacktrace of any logged Throwable (optional, default to true).
stacktraceAsString	boolean	Whether to format the stacktrace as a string, and not a nested object (optional, defaults to false).
includeNullDelimiter	boolean	Whether to include NULL byte as delimiter after each event (optional, default to false).
To include any custom field in the output, use following syntax:

  <XmlLayout>
    <KeyValuePair key="additionalField1" value="constant value"/>
    <KeyValuePair key="additionalField2" value="$${ctx:key}"/>
  </XmlLayout>
Custom fields are always last, in the order they are declared. The values support lookups.

Additional runtime dependencies are required for using XmlLayout.

YAML Layout
Appends a series of YAML events as strings serialized as bytes.

A YAML log event follows this pattern:

---
timeMillis: 1493122307075
thread: "main"
level: "INFO"
loggerName: "HelloWorld"
marker:
 name: "child"
 parents:
 - name: "parent"
   parents:
   - name: "grandparent"
message: "Hello, world!"
thrown:
 commonElementCount: 0
 message: "error message"
 name: "java.lang.RuntimeException"
 extendedStackTrace:
 - class: "logtest.Main"
   method: "main"
   file: "Main.java"
   line: 29
   exact: true
   location: "classes/"
   version: "?"
contextStack:
- "one"
- "two"
endOfBatch: false
loggerFqcn: "org.apache.logging.log4j.spi.AbstractLogger"
contextMap:
 bar: "BAR"
 foo: "FOO"
threadId: 1
threadPriority: 5
source:
 class: "logtest.Main"
 method: "main"
 file: "Main.java"
 line: 29
YamlLayout Parameters
Parameter Name	Type	Description
charset	String	The character set to use when converting to a byte array. The value must be a valid Charset. If not specified, UTF-8 will be used.
properties	boolean	If true, the appender includes the thread context map in the generated YAML. Defaults to false.
locationInfo	boolean	
If true, the appender includes the location information in the generated YAML. Defaults to false.

Generating location information is an expensive operation and may impact performance. Use with caution.

includeStacktrace	boolean	If true, include full stacktrace of any logged Throwable (optional, default to true).
stacktraceAsString	boolean	Whether to format the stacktrace as a string, and not a nested object (optional, defaults to false).
includeNullDelimiter	boolean	Whether to include NULL byte as delimiter after each event (optional, default to false).
To include any custom field in the output, use following syntax:

  <YamlLayout>
    <KeyValuePair key="additionalField1" value="constant value"/>
    <KeyValuePair key="additionalField2" value="$${ctx:key}"/>
  </YamlLayout>
Custom fields are always last, in the order they are declared. The values support lookups.

Additional runtime dependencies are required for using YamlLayout.

Location Information
If one of the layouts is configured with a location-related attribute like HTML locationInfo, or one of the patterns %C or %class, %F or %file, %l or %location, %L or %line, %M or %method, Log4j will take a snapshot of the stack, and walk the stack trace to find the location information.

This is an expensive operation: 1.3 - 5 times slower for synchronous loggers. Synchronous loggers wait as long as possible before they take this stack snapshot. If no location is required, the snapshot will never be taken.

However, asynchronous loggers need to make this decision before passing the log message to another thread; the location information will be lost after that point. The performance impact of taking a stack trace snapshot is even higher for asynchronous loggers: logging with location is 30-100 times slower than without location. For this reason, asynchronous loggers and asynchronous appenders do not include location information by default.

You can override the default behaviour in your logger or asynchronous appender configuration by specifying includeLocation="true".