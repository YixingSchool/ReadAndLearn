

record_transformer Filter Plugin | Fluentd https://docs.fluentd.org/v1.0/articles/filter_record_transformer#autotypecast-optional

Example Configurations

filter_record_transformer is included in Fluentd’s core. No installation required.

```xml
<filter foo.bar>
  @type record_transformer
  <record>
    hostname "#{Socket.gethostname}"
    tag ${tag}
  </record>
</filter>
```
The above filter adds the new field “hostname” with the server’s hostname as its value (It is taking advantage of Ruby’s string interpolation) and the new field “tag” with tag value. So, an input like

{"message":"hello world!"}
is transformed into

{"message":"hello world!", "hostname":"db001.internal.example.com", "tag":"foo.bar"}
Here is another example where the field “total” is divided by the field “count” to create a new field “avg”:

<filter foo.bar>
  @type record_transformer
  enable_ruby
  <record>
    avg ${record["total"] / record["count"]}
  </record>
</filter>
It transforms an event like

{"total":100, "count":10}
into

{"total":100, "count":10, "avg":"10"}
With the enable_ruby option, an arbitrary Ruby expression can be used inside ${...}. Note that the “avg” field is typed as string in this example. You may use auto_typecast true option to treat the field as a float.

You can also use this plugin to modify your existing fields as

<filter foo.bar>
  @type record_transformer
  <record>
    message yay, ${record["message"]}
  </record>
</filter>
An input like

{"message":"hello world!"}
is transformed into

{"message":"yay, hello world!"}
Finally, this configuration embeds the value of the second part of the tag in the field “service_name”. It might come in handy when aggregating data across many services.

<filter web.*>
  @type record_transformer
  <record>
    service_name ${tag_parts[1]}
  </record>
</filter>
So, if an event with the tag “web.auth” and record {"user_id":1, "status":"ok"} comes in, it transforms it into {"user_id":1, "status":"ok", "service_name":"auth"}.

Parameters

Common Parameters

@type

The value must be record_transformer.

<record> directive

Parameters inside <record> directives are considered to be new key-value pairs:

<record>
  NEW_FIELD NEW_VALUE
</record>
For NEW_FIELD and NEW_VALUE, a special syntax ${} allows the user to generate a new field dynamically. Inside the curly braces, the following variables are available:

The incoming event’s existing values can be referred by their field names. So, if the record is {"total":100, "count":10}, then record["total"]=100 and record["count"]=10.
tag_parts[N] refers to the Nth part of the tag. It works like the usual zero-based array accessor.
tag_prefix[N] refers to the first N parts of the tag. It works like the usual zero-based array accessor.
tag_suffix[N] refers to the last N parts of the tag. It works like the usual zero-based array accessor.
tag refers to the whole tag.
time refers to stringanized event time.
hostname refers to machine’s hostname. The actual value is result of Socket.gethostname.

# enable_ruby

When set to true, the full Ruby syntax is enabled in the ${...} expression. The default value is false.

With true, additional variables could be used inside ${}.

record refers to the whole record.
time refers to event time as Time object, not stringanized event time.
Here is the examples:

jsonized_record ${record.to_json}
avg ${record["total"] / record["count"]}
formatted_time ${time.strftime('%Y-%m-%dT%H:%M:%S%z')}
escaped_tag ${tag.gsub('.', '-')}
last_tag ${tag_parts.last}
foo_${record["key"]} bar_${record["value"]}
nested_value ${record["payload"]["key"]}

# auto_typecast

Automatically cast the field types. Default is false.

LIMITATION: This option is effective only for field values comprised of a single placeholder.

Effective Examples:

foo ${record["foo"]}
Non-Effective Examples:

foo ${record["foo"]}${record["bar"]}
foo ${record["foo"]}bar
foo 1
Internally, this keeps the original value type only when a single placeholder is used.

renew_record

type	default	version
bool	false	0.14.0
By default, the record transformer filter mutates the incoming data. However, if this parameter is set to true, it modifies a new empty hash instead.

renew_time_key

type	default	version
string	nil	0.14.0
renew_time_key foo overwrites the time of events with a value of the record field foo if exists. The value of foo must be a unix time.

keep_keys

type	default	version
array	nil	0.14.0
A list of keys to keep. Only relevant if renew_record is set to true.

keep_keys has been supported since 0.14.0
remove_keys

type	default	version
array	nil	0.14.0
A list of keys to delete.

Need more performance?

filter_record_modifier is light-weight and faster version of filter_record_transformer. filter_record_modifier doesn’t provide several filter_record_transformer features, but it covers popular cases. If you need better performace for mutating records, consider filter_record_modifier instead.

FAQ

What are the differences between ${record["key"]} and ${key}?

${key} is short-cut for ${record["key"]}. This is error prone because ${tag} is unclear for event tag or record["tag"]. So the ${key} syntax is removed since v0.14.v0.12 still supports ${key} but it is not recommended.

I got unknown placeholder ${record['msg']} found error, why?

Without enable_ruby, ${} placeholder supports only double quoted string for record field access. So use ${record["key"]} instead of ${record['key']}.

Learn More

Filter Plugin Overview