# ruby-parallel-concurrency-test

An experiment to achieve parallelism in a concurrent workload in Ruby.

Includes a reproduction of behavior I don't yet understand where when a thread is executed in JRuby, and the block of code executed includes a `puts` statement, the string printed does not have a newline.

Uses CRuby 3.1.2 or JRuby 9.3.8.0 (with Java 19 in order to use Java virtual threads).

Usage:

```
rvm use [3.1.2|jruby-9.3.8.0] && export RUBY_CMD="[ruby|jruby -J--enable-preview]"
$RUBY_CMD conc_par_via_java_threads.rb <number_of_units_of_work> <concurrency> [R|JP|JV]
```

R = Ruby threads

JP = Java platform threads

JV = Java virtual threads (requires Java 19 to be set as current Java)

Example output with reproduction of behavior described above:

```
Running with:
  Factor: 100000000
  Workload: 2
  Concurrency: 2
  Thread type: JV

Acquired semaphore permit to complete unit of work #1.
Started unit of work #1.Acquired semaphore permit to complete unit of work #2.

Started unit of work #2.
Finished unit of work #1.
Released semaphore permit after completing unit of work #1.
Joined unit of work #1.
Finished unit of work #2.
Released semaphore permit after completing unit of work #2.
Joined unit of work #2.

End.
```

Note the single line printed that lacks the expected newline:

```
Acquired semaphore permit to complete unit of work #1.
Started unit of work #1.Acquired semaphore permit to complete unit of work #2.
```
