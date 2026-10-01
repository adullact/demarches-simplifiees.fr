# frozen_string_literal: true

Spring.watch(
  ".ruby-version",
  ".rbenv-vars",
  "tmp/restart.txt",
  "tmp/caching-dev.txt"
)

# Libcurl is initialized lazily by Typhoeus when the first HTTP request is performed (usually after forking).
# As libcurl initialisation uses some Objective-C backed APIs (SCDynamicStoreCopyProxies), this can lead to the
# following crash:
#
# > +[NSCharacterSet initialize] may have been in progress in another thread when fork() was called.
# > We cannot safely call it or ignore it in the fork() child process.Crashing instead.

# The error message is slightly misleading: calling an +initialize method in a forked process will *always* crash with
# this message – regardless of the threading state.
# (https://github.com/apple-oss-distributions/objc4/blob/fb265098298302243cd7eeaa1f63f0ba7786dd9a/runtime/objc-initialize.mm#L740-L744)
#
# However, if libcurl has been initialized once before forking, so have the relevant Objective-C classes. Even if
# libcurl is initialized again in the forked process, the +initialize methods have already been called once in a
# non-forked process, so the runtime is happy.
begin
  require "typhoeus"
  Typhoeus::Pool.get
rescue LoadError
  puts "Typhoeus not available: no need to preload libcurl."
end
