---
layout: post
title: Towards better natural language learning
categories:
- software
tags:
- learning
- anki
- telegram
- bot
---

* content
{:toc}

## Background

A while ago I started to learn new languages. In the beginning, it was English, then Japanese and now German.

Since then, I have always tried to optimize this process using technologies. And since we now have a powerful computer in our pockets, I was looking for software to extend my vocabulary in a new language.

That is how I came to [Anki](https://apps.ankiweb.net).

## Anki

Briefly, it's an application or even a framework, that allows you to create [flashcards](https://en.wikipedia.org/wiki/Flashcard) and with a remarkable [spaced repetition](https://en.wikipedia.org/wiki/Spaced_repetition) algorithm learn effectively (at least for me) new things.

I'm sure everyone has their best way to learn new words in a new language, but for me, a classical method of just writing words and trying to learn them all at a time simply doesn't work. At first, it felt like I had learned, but all the new knowledge swiftly faded.

I found Anki a fantastic tool to solve the problem mentioned above:
* First, you learn new words in batches. The default setting is only **10** new words per day for a deck of words and **100** cards to repeat. The numbers are configurable, but it worked perfectly, so I don't feel overwhelmed.
* Second, the spaced repetition algorithm helps words stick to your mind. The first time, you need to repeat a word in **10** minutes, then in **3** days and after a few more times, it can be more than **1** year.


{% include image.html url="/assets/images/tech-for-language-learning/anki_heatmap.png" description="heatmap of my repetition in Anki" %}

The next puzzle we need to solve is filling Anki with the words we want to learn!

## Source of words

Many say grammar is important. I say only vocabulary can let you speak freely.

What could be the best source of new words? For me, the answer is simple: **books**.

But the problem with books is that reading the whole book in a language you're not fluent in can be challenging. It's also hard for your brain without seeing progress, and it can be even more difficult with books.
You can start with books for children, but if you're not a kid, it could be not very attractive.

For me, the answer was Japanese comics called [manga](https://en.wikipedia.org/wiki/Manga).
The beauty of manga is that it's made for all ages. Also, many genres and beautiful drawings made it very attractive to me.
My choice was ["Dorohedoro"](https://en.wikipedia.org/wiki/Dorohedoro) translated into German.
It has everything I need: an exciting story, beautiful drawings and a tons of informal lexicon.

{% include image.html url="/assets/images/tech-for-language-learning/me_reading_manga.jpg" description="me reading manga" %}


## Messengers to the rescue

Now we have two most important pieces: **Anki** and **books**.

The problem we still have is that adding words from the book to Anki is difficult.

You can use the Anki mobile application to add new words, but it was not the easiest solution for me. When learning a new language, it's crucial to make the process as simple as possible. Otherwise, it's easy to get frustrated and quit.

What can solve this issue? Something I use every day.

The answer is messengers, particularly [Telegram](https://telegram.org).
I spent some time designing and developing a telegram bot [Anker](https://github.com/szobov/anker).

![bot interface](/assets/images/tech-for-language-learning/bot_chat.jpg)

The UI of this interface is simple: you choose a language and a deck and send it a word to translate. Then, it creates a card from the word and translation.
After syncing the app with the cloud, it appears as this nicely-looking card:

![anki interface](/assets/images/tech-for-language-learning/anki_interface.jpg)

Now, we have all the pieces to improve our vocabulary drastically.


## Conclusion

I stopped learning Japanese as soon as I decided to relocate to Germany. I mostly forgot all the grammar I knew, but I still can understand the words I learned using Anki.

After my weekly German lesson, I add new words to my learning deck. Anki made it scalable for me. It gives me confidence that I don't waste my time in the learn-and-forget loop but have slow, steady progress.

I understand that the method I describe in this article can only fit some people, but I hope you can try it and it can work for you.
