# IO::Async based Bot

A Bot based on IO::Async which is fully pluggable, and not necessarily for IRC, honest guv

# Running

run `script/plugbot.pl` in one terminal, then run `socat unix:plugbot.sock
stdio` in another for now. Run as many `socat` processes you want.

The inter-process communication is done entirely in JSON
hashes/dictionaries/whatever they're known as. With `socat` you can just write
straight into stdio if you used the example command above.

The only defined part of the JSON is the "cmd" key, which takes a string value
which you can define. There are only two pre-defined communication commands,
'watch' and 'unwatch'.

to watch a particular endpoint for a command, (for example, to watch for `text`
commands) send the following JSON:

  {"cmd":"watch","args":"text"}

This endpoint will now be sent all commands which have a `cmd` of `text`.

To unwatch, it is a very similar process:

  {"cmd":"unwatch","args":"text"}

Now when a `text` command is sent, you will receive the identical message.

Note that if you 'subscribe' to a command which you also will be sending, when
you send that command message you WILL receive it back as well - this is up to
you to deal with!

Commands can be whatever you want as long as they contain the `cmd` key, any
other keys can be whatever you want.
