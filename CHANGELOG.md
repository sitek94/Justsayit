# Changelog

## 0.0.2

I greatly improved the settings view - styled it and got it very close to what I want in the final version. Most of it is just mocks right now, but at least I know how I want the settings view to look.

I also got paste-at-cursor working. Now when you finish transcribing and press stop, once the transcription is done and you move your cursor to another application, the transcribed text gets pasted at that cursor position.

Finally, I verified what permissions we actually need in info.plist and entitlements, and confirmed we can use app sandbox. I had a lot of trouble implementing paste-at-cursor - initially I tried using Apple Events and Apple Script, sending command+V through Apple Events. I kept adding stuff to the plist files and entitlements trying to make it work, but it was really flaky. In the end I switched to CGEvent and that actually works. After getting it working, I removed all the unnecessary stuff I'd added to the plist files and entitlements. So this version has the minimum required permissions, including app sandbox. If I have problems in future versions and start messing around with permissions again, I can look back at 0.0.2 to see what's actually needed. Everything's tested and working well at this point, including paste-at-cursor.

## 0.0.1

Initial release with basic functionality and division into different services. The main pipeline is very similar to SuperWhisper - basically a SuperWhisper clone. We have a little view where pressing start begins recording audio. The audio saves in app documents. Once saved, we take the audio and send it to OpenAI for transcription. Then we pass the transcription to an AI processing service, which is just a stub for now - it just returns the text, but I wanted it in the pipeline to show what's happening. After that, I copy to clipboard. Paste-at-cursor isn't implemented yet at this point.

I also set up the whole pipeline for automatic GitHub releases, building and signing. The only reason it's not working at this stage is the private repository - the application can't fetch GitHub releases from a private repo, but it'll work once I make the repository public.