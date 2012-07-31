MOCompletionTextField
=====================


Introduction
------------

Subclass of `UITextField` that remembers previous entries and displays
a view with possible completions above the keyboard. The entries are
stored in a string trie (http://en.wikipedia.org/wiki/Trie) that can
by written to disc.

![](https://github.com/plancalculus/MOCompletionTextField/raw/master/Screenshots/MOCompletionTextFieldExample1.png)
![](https://github.com/plancalculus/MOCompletionTextField/raw/master/Screenshots/MOCompletionTextFieldExample2.png)


Features
--------

A `MOCompletionTextField` can be used as a replacement for
`UITextField`. If multiple text fields are supposed to provide
identical completions construct a string trie by invoking

    [[MOStringTrie alloc] init] 

and set the `completionStringTrie` property of all the text fields to
this trie. If you have written the trie to disc you can use

   [[MOStringTrie alloc] initWithContentsOfFile:filePath]

to initialise it. The library comes with an example project that
provides a table view with text fields that all share one trie. The
property `completionEnumerationStyle` of a text field can be used to
specify the order of the enumeration. Currently completions can be
ordered lexicographically as well as by frequency of their uses.


Usage
-----

Import the static library as a sub-project into your main project.


Requirements
------------

XCode 4.2 or later and iOS 4 or later as the module uses automatic
reference counting.


License
-------

`MOCompletionTextField` is released under Modified BSD License.