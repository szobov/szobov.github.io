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

I wrote this article with assumption that reader has some a prior knowledge about [JavaScript](https://developer.mozilla.org/en-US/docs/Web/javascript), [bytes](binary data), and [Presentation layer](https://en.wikipedia.org/wiki/Presentation_layer).
You may still benefit from reading if you don't have it, but it may be too boring. With a prior knowledge it is still boring, but probably less. :)


## Background

As I describe in my previous [blog post]({% post_url 2023-10-22-towards-better-natural-language-learning %}) I wrote a [telegram bot](https://github.com/szobov/anker) to simplify cards creation in [Anki](https://www.ankiweb.net).

In this article I'll describe some technical issues I faced in integration with Anki, particularly about reverse engineering their communication protocol.


## Promising beginning

Anki doesn't provide a public HTTP API.

When I started my integration by spending a few minutes in [dev-console](https://developer.chrome.com/docs/devtools/) and I quickly realize that Ankiweb is working by simply sending GET/POST requests with [forms](https://developer.mozilla.org/en-US/docs/Learn/Forms). Sounds easy, right? Speaking honestly, it was easy. The implementation took me an hour and the client was fully functional.

Everything worked smoothly, but then it suddenly broke.

## Broken API

If there is no public API, there are no promises. I should have expected it.

My bot stopped adding cards to Anki and was not even able to login.
I spend some time figuring it out and understood, the API has changed and Anki no more simply sending forms.

I still had a strong desire to add my words to my decks, so my next Journey has began.

## Reverse engineering

Ankiweb was still using HTTP-requests and cookies to preserve the authentification information.
It means that I should be able to reproduce what Ankiweb's frontend is doing.

The first issue I faced was: I was not able to see response on request in dev console. It simple shown me: 

![no response](/assets/images/reverse-engineering-anki/anki_console_failed_to_load_response.png)

Ouch! It was a little bit frustrating, because I was sure it should somehow exchange the data. Otherwise, how does it work?

Then I looked into login request's payload. I also set a password to start from a very particular string, so it will be easy to spot it into logs.

{% include image.html url="/assets/images/reverse-engineering-anki/loging_password_symbols.png" description="payload of the login request" %}

Nothing very suspicious with except of "" and ")" symbols.
It felt like there is some binary data transfered around, but what can it be?

I started to look in the source code of web page.
Obviously, it was minified and obfuscated, literally just a bunch of unreadable JavaScript expression joined in one infinitely long string.
```javascript
{if(r=V[n.charCodeAt(c)],r===void 0)switch(n[c]){case"=":a=0;case`
`:case"\r":case"	":case" ":continue;default:throw Error("invalid base64 string.")}switch(a){case 0:i=r,a=1;break;case 1:s[t++]=i<<2|(r&48)>>4,i=r,a=2;break;case 2:s[t++]=(i&15)<<4|(r&60)>>2,i=r,a=3;break;case 3:s[t++]=(i&3)<<6|r,a=0;break}}if(a==1)throw Error("invalid base64 string.");return s.subarray(0,t)},enc(n){let e="",s=0,t,a=0;for(let r=0;r<n.length;r++)switch(t=n[r],s){case 0:e+=S[t>>2],a=(t&3)<<4,s=1;break;case 1:e+=S[a|t>>4],a=(t&15)<<2,s=2;break;case 2:e+=S[a|t>>6],e+=S[t&63],s=0;break}return s&&(e+=S[a],e+="=",s==1&&(e+="=")),e}}
```

A pile of junk, but can we make use of it?

Browsers are our friend in reverse engineering frontends. For example, Chromium provides [pretty-printing option](https://developer.chrome.com/docs/devtools/javascript/reference/#format) for minified JavaScript.
After pretty-printing it we get something like this:
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

Still hard to read, since it's minified, but we give us to advantages:
1. It's easy to find the places where requests are done, since we can directly search for substrings.
2. The most important point: it's now easy to set a debugger breakpoints and check all values in runtime.

I set a debugger right into the code, where request happened and it quickly lead me to another request, which was not displayed in the dev-console for some reasons.
It turned out there is a banch of requests that starts with `/svc/` prefix. The one that was particularly interesting is here:

![no response](/assets/images/reverse-engineering-anki/anki_svc_account.png)

So, I move into this function.
```javascript
async function u(n, e, s, t) {
    const a = e.toBinary()
      , r = await ne(n, a, t);
    return s.fromBinary(r)
}
```
What's happing here is definitly something important for request forming:
1. `e` contains our login and password information in such format: `{username: 'by***', password: 'pass***'}`
2. Then, using some logic, code makes a binary array from it and sends it the server.
3. In case of success it receive a bunch of bytes back and decodes it back to the JavaScript object.

Now my problem is to figure out what is this "logic" behind encoding and deconding data between requests and response from server.
First, I looked into `e.toBinary()` function, since encoding happend here.
By jumping back and forth I got to the following object:
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
On a bright side it already gives some insight, on the other side it's still not clear how this object is formed.
I started to dig deeper, right into the sibling of `toBinary()` function: `fromBinary()`
Let's now look closely to this function:
```javascript
    fromBinary(e, s) {
        const t = this.getType()
          , a = t.runtime.bin
          , r = a.makeReadOptions(s);
        return a.readMessage(this, r.readerFactory(e), e.byteLength, r),
        this
    }
```
where the paramer "e" contains the binary data received from the robot. I also checked that the output of this function is the nicely formed object.
I was lucky to get a jackpot from the first guess, I printed `t.runtime` object:
```
> t.runtime
< {syntax: 'proto3', json: {…}, bin: {…}, util: {…}, makeMessageType: ƒ, …}
```
You may wonder, why I was so happy to see this object?
Because of the "proto3" strings, which immidiatly clicked in my mind: it's a [protobuf](https://protobuf.dev)!
And now the object I mentoned a few lines above makes perfect sense: it's a message reperesentaton from the protobuf!
Armed with this knowledge, I started to craft the protobuf messages from the object I got from the dev console.

A few words about protobuf:
I already mentioned it [one]({% post_url 2019-02-16-prototext-human-readable-protobuf %}) of my old articles. Basically, it's a binary serialization protocol, likely OSI level 6, and compiler, which is widely used and is a corner stone of [gRPC](https://grpc.io) technology. You simply describe the message structure and then it automatically creates a code to handle it.

So, I formed a first login message an transfered it from my code.
Ta-da! It worked. We just creacked this nut.

Unfortunatelly, quite quickly I realized, that something is still missing in my messages.
They seems to work nice, but sometime for some requests server responded with the error.

I looked more closely to the data I de-serialized from the server and notice a some peculiar values for ids. For example, `deck_id` has a value `-143234` and it clearly sounded like a bug. Again, I was lucky to solve this issue from the first guess: initially I used `int32` format for int values, probably because it's not clear from the object in cosole it uses. I switched to `uint64` and all issues were resolved.

## implementation

https://github.com/szobov/anker/pull/7/files



* Write about requests in dev console. Highligh that response was not displayed in the console.
* Write about minified javascript.
* Write about magic "proto3" string in the response and fields not minified (like "token")
* Write about protobuf
* Write about wrong int32 (uint64)
