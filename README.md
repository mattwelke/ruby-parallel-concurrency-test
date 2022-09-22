# ruby-parallel-concurrency-test

An experiment to achieve parallelism in a concurrent workload in Ruby.

Includes a reproduction of behavior ~~I don't yet understand~~ [explained in an answer to a Stack Overflow question I posted](https://stackoverflow.com/questions/73767973/why-does-jruby-sometimes-not-print-a-newline-at-the-end-of-the-string-when-puts) where when a thread is executed in JRuby, and the block of code executed includes a `puts` statement, the string printed sometimes does not have a newline.

Uses CRuby 3.1.2 or JRuby 9.3.8.0 (with Java 19 in order to use Java virtual threads).

Usage:

```
rvm use [3.1.2|jruby-9.3.8.0] && export RUBY_CMD="[ruby|jruby -J--enable-preview]"
$RUBY_CMD par_conc.rb <number_of_units_of_work> <concurrency> [R|JP|JV]
```

R = Ruby threads

JP = Java platform threads

JV = Java virtual threads (requires Java 19 to be set as current Java)

## Example

If we run:

```bash
rvm use jruby-9.3.8.0 && export RUBY_CMD="jruby"
$RUBY_CMD par_conc.rb 3 2 R
```

We can get the following output:

```
Running with:
  Factor: 100000000
  Workload: 3
  Concurrency: 2
  Thread type: R

Started unit of work #2.Started unit of work #1.

Finished unit of work #2.
Started unit of work #3.
Finished unit of work #1.
Finished unit of work #3.

End.
```

Note the single line printed that lacks the expected newline:

```
Started unit of work #2.Started unit of work #1.
```
