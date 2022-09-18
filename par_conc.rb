require 'concurrent'

# Config:

# The amount of work to perform in each unit of work.
FACTOR=100000000

# The number of units of work to perform in total.
WORKLOAD=Integer(ARGV[0])

# The number of units of work to perform concurrently, with as much as possible
# being performed concurrently also being performed in parallel (ex. 8 in
# parallel on a 4 core, 8 thread CPU). This will be the number of virtual
# threads to start simultaneously.
CONCURRENCY=Integer(ARGV[1])

# The type of thread to use to run each block of code for a unit of work.
# Valid values:
#   R (Ruby thread)
#   JP (Java platform thread)
#   JV (Java virtual thread)
THREAD_TYPE=ARGV[2]

puts "Running with:"
puts "  Factor: #{FACTOR}"
puts "  Workload: #{WORKLOAD}"
puts "  Concurrency: #{CONCURRENCY}"
puts "  Thread type: #{THREAD_TYPE}"
puts

def work(factor, n)
  puts "Started unit of work ##{n}."
  i = 0
  factor.times { i += 1 }
  puts "Finished unit of work ##{n}."
end

startables = []

# Use a semaphore to restrict the number of runnables we allow to be running at
# simultaneously.
semaphore = Concurrent::Semaphore.new(CONCURRENCY)

WORKLOAD.times do |i|
  n = i + 1

  startable = Proc.new do
    semaphore.acquire do
      work(FACTOR, n)
    end
  end

  startables.push({s: startable, n: n})
end

threads = []

# Centralizing logic for choosing which type of thread will be used to run the
# block of code for a work unit. This method also starts the thread immediately
# before returning because Ruby threads must be started immediately and
# "Ruby thread" is one of the valid configuration values for thread type.
def get_thread(proc)
  if THREAD_TYPE == "R"
    thread = Thread.new &proc
    return thread
  end
  if THREAD_TYPE == "JP"
    thread = java.lang.Thread.new(proc)
    thread.start
    return thread
  end
  if THREAD_TYPE == "JV"
    thread = java.lang.Thread.ofVirtual
    return thread.start(proc)
  end
end

startables.each do |s|
  thread = get_thread(s[:s])
  threads << {t: thread, n: s[:n]}
end

threads.each do |t|
  t[:t].join
end

puts "\nEnd."
