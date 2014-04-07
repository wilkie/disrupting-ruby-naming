# Disrupting Ruby Naming

**In the source files below, 'slash' means it is in a subdirectory. subdirectories are not allowed in gists.**

Let's say you, a native Spanish speaker, wanted to write some code and use a library, but you wanted it to be equally functional to a library that already exists, but have Spanish names. So far, our community has been focused on and expecting that everybody learn English. This is enforced in several places, but primarily in our programming languages. Let us be code librarians and ask ourselves: shouldn't we change that?

## C

At first, I terrorized C's standard library by replacing the function names [with those readable in Spanish](http://pastebin.com/eMUV82mb). It was a good time.

C is actually rather easy. It has a linking stage! This means it has a preprocessing step of turning code into machine language where it is placed into permanent, static, relative positions. It is like when typesetting a book... you put the chapters in order, you know what pages they fall on to make the table of contents. At the end of the day, why consult the table of contents every time? Just replace references to chapters with page numbers. "Refer to 'Chapter 2: Introducing Linear Algebra'" can just be "Go to page 52." That's what a compiler ultimately does. But, in the intermediate step, it uses the names to know how to organize and lay out the code mostly because humans read and write it and also because it doesn't know where these chapters/functions will ultimately end up.

So names get replaced with their positions anyway. So renaming a function (adding something redundant to the table of contents) is relatively easy. You either tell the linker (the program that does this) to map a new name to an existing address, which is how the above works, or you tell the compiler to generate new symbols when compiling the original file. Easy. Basically: computers hate names, so you can override them.

## Ruby

Interpreted/dynamic languages are a different story. They let you alter the table-of-contents structure that maps names to code while the program is running. If you change the name of something, other pieces of code won't know how to look it up by its old name! We got away with it above because that lookup never changed.

If you don't like the names somebody else has chosen for you, well, what are you going to do? If you alias their name, then somebody else's code who likes/tolerates that name will suddenly not work with your code. That's not good. Collaboration is important, regardless of how bad/political the function names of a library happen to be.

So, you have to embrace the dynamic nature in order to support renaming/reorganization. I've focused here on simply renaming methods, but for the rubyists out there: renaming classes is similar (in ruby, classes are constants defined within modules... so theoretically a similar process would be perfectly fine!)

So now, when you call a renamed method on a class, it does a lookup and decides, based on where you've called it (the source file's location,) which methods are actually available. It keeps a mapping of source files to name lists and knows how to map those names to the original functions. The original functions are not available in a different namespace, for example "Spanish."

I've basically completely hijacked the language's method dispatcher.

So, if you have a program 'moo_en' and it is using the engUS version of Foo, then it can only call 'say' and not 'decir' which is available for the spaES version of Foo. Yet, if moo_en uses Carol's code which is written in Spanish, it will not conflict, in spite of ruby's dynamic nature. Neat.

Below is such a situation. moo_en.rb uses the English renaming of the Foo class (see: original/foo.rb vs engUS/foo.rb) and moo_es.rb uses the Spanish renaming, so it only responds to Foo.decir. Yet moo2.rb doesn't specify. So it uses the original programmers' names. Even though both moo_en.rb and moo_es.rb use moo2.rb for their own use, this doesn't conflict at all. moo2.rb is agnostic to that choice and works fine in both environments.

You could ultimately replace the entirety of ruby's libraries with your own names and abstractions without disrupting other libraries. And you could write code within the same environment as others, but your environment looks completely different (in a different language, in this case)
