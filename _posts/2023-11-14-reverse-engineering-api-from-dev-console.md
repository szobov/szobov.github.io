---
layout: post
title: Reverse engineering binary protocol from dev console
categories:
- software
tags:
- "reverse engineering"
- anki
- frontend
---


* content
{:toc}

## Prerequisites

I wrote this article with the assumption that the reader has some prior knowledge about [JavaScript](https://developer.mozilla.org/en-US/docs/Web/javascript), [bytes](binary data), and [Presentation layer](https://en.wikipedia.org/wiki/Presentation_layer).
If you don't have it, you may still benefit from reading, but it may be too boring. With prior knowledge, it is still boring, but less. ;)


## Background

As I describe in my previous [blog post]({% post_url 2023-10-22-towards-better-natural-language-learning %}) I wrote a [telegram bot](https://github.com/szobov/anker) to simplify cards creation in [Anki](https://www.ankiweb.net).

In this article, I'll describe some technical issues I faced in integrating with Anki, particularly reverse engineering their communication protocol.


## Promising beginning

Anki doesn't provide a public HTTP API. At least on a date of writing this article.

When I started my integration by spending a few minutes in [dev-console](https://developer.chrome.com/docs/devtools/), I quickly realized that Ankiweb is working by simply sending [GET/POST requests](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods) with [forms](https://developer.mozilla.org/en-US/docs/Learn/Forms). Sounds easy, right? Speaking honestly, it was easy. The implementation took me an hour, and the client was fully functional.

Everything worked smoothly, but then it _suddenly_ broke.

## Broken API

If there is no public API, there are no promises. I should have expected it.

My bot stopped adding cards to Anki and could not even log in.
I spent some time figuring it out and understood that the API has changed, and Anki is no longer simply sending forms.

I still strongly desired to add words to my decks, so my next Journey began.

## Reverse engineering

Ankiweb was still using HTTP requests and cookies to preserve the authentification information.
It means I should be able to reproduce what Ankiweb's front end is doing.

My first issue was that I could not see the response to requests in the dev console. It simply showed me: 

![no response](/assets/images/reverse-engineering-anki/anki_console_failed_to_load_response.png)

Ouch! It was a bit confusing because I was sure it should somehow exchange the data. Otherwise, how does it work?

Then, I looked into the login request's payload. I also set a password to start from a very particular string so it will be easy to spot it in logs.

{% include image.html url="/assets/images/reverse-engineering-anki/loging_password_symbols.png" description="payload of the login request" %}

Nothing very suspicious except for"" and ")" symbols.
It felt like some binary data was transferred around, but what could it be?

I started to look at the source code of the web page.
Obviously, it was minified and obfuscated. Literally, just a bunch of unreadable JavaScript expressions joined in one infinitely long string.
```javascript
{if(r=V[n.charCodeAt(c)],r===void 0)switch(n[c]){case"=":a=0;case`
`:case"\r":case"	":case" ":continue;default:throw Error("invalid base64 string.")}switch(a){case 0:i=r,a=1;break;case 1:s[t++]=i<<2|(r&48)>>4,i=r,a=2;break;case 2:s[t++]=(i&15)<<4|(r&60)>>2,i=r,a=3;break;case 3:s[t++]=(i&3)<<6|r,a=0;break}}if(a==1)throw Error("invalid base64 string.");return s.subarray(0,t)},enc(n){let e="",s=0,t,a=0;for(let r=0;r<n.length;r++)switch(t=n[r],s){case 0:e+=S[t>>2],a=(t&3)<<4,s=1;break;case 1:e+=S[a|t>>4],a=(t&15)<<2,s=2;break;case 2:e+=S[a|t>>6],e+=S[t&63],s=0;break}return s&&(e+=S[a],e+="=",s==1&&(e+="=")),e}}
```

It is a pile of junk, but can we make use of it?

Browsers are our friend in reverse engineering frontends. For example, Chromium provides [a pretty-printing option](https://developer.chrome.com/docs/devtools/javascript/reference/#format) for minified JavaScript.
After pretty-printing it, we get something like this:
```javascript
    if (a.status === 403)
        return window.location.href = "/account/login",
        new Uint8Array;
    if (!a.ok) {
        let c = a.statusText;
        try {
            c = await a.text()
        } catch {}
        throw Oe(a.status, c)
    }
```

Still hard to read since it's minified, but it gives us two advantages:
1. It's easy to find where requests are made since we can directly search for substrings.
2. The most essential point: it's now easy to set debugger breakpoints and check all values in runtime.

I set a debugger right into the code where the request happened, and it led me to another request, which was not displayed in the dev console for some reason.
It turned out there are many requests that start with the `/svc/` prefix. The particularly interesting one is here:

![no response](/assets/images/reverse-engineering-anki/anki_svc_account.png)

So, I moved into this function.
```javascript
async function u(n, e, s, t) {
    const a = e.toBinary()
      , r = await ne(n, a, t);
    return s.fromBinary(r)
}
```
What's happening here is definitely something important for request forming:
1. `e` contains our login and password information in such format: `{username: 'by***', password: 'pass***'}`
2. Then, using some logic, the code makes a binary array from it and sends it to the server.
3. In case of success, it receives a bunch of bytes and decodes them back to the JavaScript object.

Now, my problem is figuring out the "_logic_" behind encoding and decoding data between requests and responses from the server.
First, I looked into the `e.toBinary()` function since encoding happened here.
By jumping back and forth, I got to the following object:
```
0: 
    T: 9
    jsonName: "username"
    kind: "scalar"
    localName: "username"
    name: "username"
    no: 1
    packed: false
    repeated: false
    [[Prototype]]: Object
1: 
    {no: 2, name: 'password', kind: 'scalar', T: 9, localName: 'password', …}
    
```
On the bright side, it already gives some insight; on the other side, how this object is formed is still unclear.
I started to dig deeper into the sibling of the `toBinary()` function: `fromBinary()`.
Let's now look closely at this function:
```javascript
    fromBinary(e, s) {
        const t = this.getType()
          , a = t.runtime.bin
          , r = a.makeReadOptions(s);
        return a.readMessage(this, r.readerFactory(e), e.byteLength, r),
        this
    }
```
Where the parameter "_e_" contains the binary data received from the server. I also checked that the output of this function is a nicely formed object.

I was lucky to get a jackpot from the first guess, and I printed the `t.runtime` object:
```
> t.runtime
< {syntax: 'proto3', json: {…}, bin: {…}, util: {…}, makeMessageType: ƒ, …}
```
You may wonder why I was so happy to see this object.

Because of the "**proto3**" strings, which immediately clicked in my mind: it's a [protobuf](https://protobuf.dev)! 🔥

And now the object I mentioned a few lines above makes perfect sense: it's a message representation from the protobuf!
Armed with this knowledge, I started to craft the protobuf messages from the object I got from the dev console.

_A few words about protobuf_:
I already mentioned it [one]({% post_url 2019-02-16-prototext-human-readable-protobuf %}) of my old articles. It's a binary serialization protocol, likely [OSI level](https://en.wikipedia.org/wiki/OSI_model) 6, and compiler, which is widely used and a cornerstone of [gRPC](https://grpc.io) technology. You describe the message structure, and then it automatically creates a code to handle it.

So, I formed a first login message and transferred it from my code.
Ta-da! It worked. We cracked this nut.

Unfortunately, I quickly realised something was still missing in my messages.
They work nicely, but sometimes, the server responds with an error for some requests.

I looked more closely at the data I de-serialized from the server and noticed some peculiar values for IDs. For example, `deck_id` has a value `-143234`, which clearly sounded like a bug, probably [interger overflow](https://en.wikipedia.org/wiki/Integer_overflow). Again, I was lucky to solve this issue from the first guess: I initially used the `int32` format for int values, probably because it's unclear from the object in the console. I switched to `uint64`, and all issues were resolved.

## Result

The resulting implementation of the API client can be found [here](https://github.com/szobov/anker/pull/7/files#diff-c5164c8415a8ff32b8b3a13ed081dc65ddb8a26594afd606d7b102dbeb875630).

The interface became more consistent, so I'm very much thankful to Anki's maintainers for this change. It was an exciting journey, and I didn't regret any time spent on it.
