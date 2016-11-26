# httspeech

A Ruby microservice(tm) that uses the `say` utility on OS X to dynamically render audio.

I hacked this together as a local TTS engine cause the free ones you can get on the internet tend to suck.

## How to use

Clone the repo.

```
bundle install
PORT=8000 bundle exec ruby app.rb`
curl http://localhost:8000/who%20let%20the%20dogs%20out.mp4 | file -
# /dev/stdin: ISO Media, MP4 v2 [ISO 14496-14]

# Voices
curl http://localhost:8000/hello%20world/Alex.mp4

# See list of voices with `say -v "?"`
```

## Limitations

* Only supports `GET`, thus probably has limitation problems
* Only renders MP4 audio

## License

MIT.
