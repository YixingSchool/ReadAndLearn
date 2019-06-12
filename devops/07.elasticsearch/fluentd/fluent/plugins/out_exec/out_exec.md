https://docs.fluentd.org/v1.0/articles/out_exec

Example Configuration

out_exec is included in Fluentd’s core. No additional installation process is required.

<match pattern>
  @type exec
  command cmd arg arg
  <format>
    @type tsv
    keys k1,k2,k3
  </format>
  <inject>
    tag_key k1
    time_key k2
    time_format %Y-%m-%d %H:%M:%S
  </inject>
</match>
Please see the Config File article for the basic structure and syntax of the configuration file.
Example: Running FizzBuzz against data stream

This example illustrates how to run FizzBuzz with out_exec.

We assume that the input file is specified by the last argument in the command line (“ARGV[-1]”). The following script fizzbuzz.py runs FizzBuzz against the new-line delimited sequence of natural numbers (1, 2, 3…) and writes the output to “foobar.out”.
```sh
#!/usr/bin/env python
import sys
input = file(sys.argv[-1])
output = file("foobar.out", "a")
for line in input:
    fizzbuzz = int(line.split("\t")[0])
    s = ''
    if fizzbuzz%3 == 0:
        s += 'fizz'
    if fizzbuzz%5 == 0:
        s += 'buzz'
    if len(s) > 0:
        output.write(s+"\n")
    else:
        output.write(str(fizzbuzz)+"\n")
output.close
```
Note that this program is written in Python. For out_exec (as well as out_exec_filter and in_exec), the program can be written in any language, not just Ruby.

Then, configure Fluentd as follows

<source>
  @type forward
</source>
<match fizzbuzz>
  @type exec
  command python /path/to/fizzbuzz.py
  <buffer>
    @type file
    path /path/to/buffer_path
    flush_interval 5s # for debugging/checking
  </buffer>
  <format>
    @type tsv
    keys fizzbuzz
  </format>
</match>
The “format tsv” and “keys fizzbuzz” tells Fluentd to extract the “fizzbuzz” field and output it as TSV. This simple example has a single key, but you can of course extract multiple fields and use “format json” to output newline-delimited JSONs.

The intermediary TSV is at /path/to/buffer_path, and the command python /path/to/fizzbuzz.py /path/to/buffer_path is run. This is why in fizzbuzz.py, it’s reading the file at sys.argv[-1].

If you start Fluentd and run

$ for i in `seq 15`; do echo "{\"fizzbuzz\":$i}" | fluent-cat fizzbuzz; done
Then, after 5 seconds, you get a file named foobar.out.

$ cat foobar.out
1
2
fizz
4
buzz
fizz
7
8
fizz
buzz
11
fizz
13
14
fizzbuzz
Supported modes

Asynchronous
See Output Plugin Overview for more details.

Plugin helpers

inject
formatter
compat_parameters
child_process
Parameters

Common Parameters

@type

The value must be exec.

command

type	default	version
string	Nothing	0.14.0
The command (program) to execute. The exec plugin passes the path of a TSV file as the last argument.

command_timeout

type	default	version
time	270	0.14.9
Command (program) execution timeout.

<format> section

See Format section configurations for more details.

@type

type	default	version
string	tsv	0.14.9
The format used to map the incoming events to the program input.

Overwrite default value in this plugin.

<inject> section

See Inject section configurations for more details.

time_type

type	default	version
string	string	0.14.9
Overwrite default value in this plugin.

localtime

type	default	version
bool	false	0.14.9
Overwrite default value in this plugin.

<buffer> section

See Buffer section configurations for more details.

delayed_commit_timeout

type	default	version
time	300	0.14.9
Overwrite default value in this plugin.