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

Some time ago I started to learn new languages. In the beginning it was English, then Japanese and now German.

Since then, I was always trying to optimize this process using technologies. And since we now have a powerful computer in our pockets I was looking for the software, that can let me extend my vocabulary in a new language.

That how I came to [Anki](https://apps.ankiweb.net). Briefly, it's an application or even a framework, that allows you to create [flashcards](https://en.wikipedia.org/wiki/Flashcard) and with a special [spaced repetition](https://en.wikipedia.org/wiki/Spaced_repetition) algorithm learn effectively (at least for me) new things.

I'm sure everyone has it's own best way to learn new words in a new language, but for me a classical method of just writing words and trying to learn them all at once simply doesn't work. At first it feels like I learned, but all the new knowledge swiftly fade.

I found Anki an amazing tool to solve aforementioned problem.
But the only thing that make me straggle is creating a new deck with flashcards.

Especially after my relocation when it bacame urgent to learn a new language and I wanted to learn words that I see and use in my daily life.
That's how I came up to an idea of using a chat bot, which will help me to add everything I see in my daily life to a deck of flashcards.

## Source of words

Many says grammar is import, but I say only vocabulary can let you speak freely.

What could be the best source of new words? For me the answer is simple: books.

But the problem of books that it can be very hard to read the whole book on a language you're not fluent at. I think, it's also hard to you brain without seeing progress and with books it can be hard.
You can start with books for children, but if you're not a kid it could be not very attrective.

For me the answer was Japanese comics called [manga](https://en.wikipedia.org/wiki/Manga).
The beuty of manga is in the idea that it's made for all ages. Also many genres and beautful drawings made it very attractive to me.
My choice was ["Dorohedoro"](https://en.wikipedia.org/wiki/Dorohedoro) translated in German.
It has everything I need: the interesting story, wonderful drawings and a tons of informal lexicon.

## Messengers to the rescue

Now we have to most important pieces: Anki and books. The problem we still have: it's not very easy to add words from book to Anki.
Of course, you can use Anki mobile application to add new words, but for me it was not the easiest solution. When you are learning new lenguage it's important to make the process as simplier is possible, otherwise it's easy to get frustrated and quit.
What can solve this issue? Something I use everyday. The answer is messengers, particularly [Telegram](https://telegram.org).
I spent sometime and designed and developed a telegram bot [Anker](https://github.com/szobov/anker).

![bot interface](/assets/images/tech-for-language-learning/bot_chat.jpg)

The UI of this interface is simple: you choose a language and a deck and send it a word to translate. Then it creates a card from the word and translation.
After syncing the app with the cloud it appears as this nicely looking card:
![anki interface](/assets/images/tech-for-language-learning/anki_interface.jpg)


## Conclusion

Bot's are nice and easy to distribute. It helped me and my friends to find an apartment in Berlin and also track my life.
Now it will also help me to ease my life in a new country.
