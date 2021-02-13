---
layout: post
title: Sneaky Strings
category: development
tags: "quirks, c#"
---

I was recently enjoying one of my favorite podcasts (shoutout to [CodingBlocks.NET](https://www.codingblocks.net/)) when I heard something that I had to test out for myself...

This was in a side conversation regarding the .NET CLR and how the language handles strings behind the scenes. Take a look at the code snippet below and see if you can correctly predict the resulting output.

```csharp
var str1 = "hello";
var str2 = "hello";
Console.WriteLine(Object.ReferenceEquals(str1, str2));
str2 = "world";
Console.WriteLine(Object.ReferenceEquals(str1, str2));
str2 = str1;
Console.WriteLine(Object.ReferenceEquals(str1, str2));
```

When I wrote out this example I believed to my core that the result would be `false false true`. Though as you may have guess, if that were the case this would be a very meaningless post...so what is the actual result? To my surprise it's `true false true`!

What's happening behind the scenes is .NET knows these two string variables hold the same value and so optimized the storage needs by pointing them to the same reference location. What's more incredible is when one of the variables is edited so that they don't match the .NET CLR is smart enough to break them into two separate references, otherwise you wold change both when you only intended to change one!

A pretty small functionality, but I found it pretty amazing nonetheless.