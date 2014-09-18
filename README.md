c2
--

c2 is a proof of concept replacement for the [chronicle blog compiler](http://www.steve.org.uk/Software/chronicle/).

This implementation is significantly faster at page generation than the
original chronicle, primarily because posts are parsed and inserted into
an SQLite database, rather than having each post read into RAM.

Once the blog posts have been populated in the SQLite database they are
inserted into a series of templates, which ultimately generates the output.

> Although we assume you keep the SQLite database around it doesn't matter if you delete it.  The act of parsing all your entries is still a very quick process.


User-Visible Changes
--------------------

In an ideal would you should be able to migrate from Chronicle directly
to this codebase, as there are a lot of commonalities:

* Blog entries are are still read from `data/`.
* Blog entries are still build up of a header and the entry.
* Entries are still parsed in HTML, Markdown, and Textile formats.

However there are changes, and these largely relate to the templates,
along with the implementation differences.

The previous Chronicle codebase was comprised of a few different binaries,
the new has only the single driver `c2` and a signification collection of
plugins.

The driver script parse arguments, and the blog posts, but the actual
generation of your site is entirely plugin-based.  The plugins are standard
Perl modules located beneath the `Chronicle::Plugin` namespace, and
although you don't need to know any of the details they can be ordered
thanks to the use of [Module::Pluggable::Ordered](http://search.cpan.org/perldoc?Module%3A%3APluggable%3A%3AOrdered) class.

The template changes are a little more signficant than I'd like, but
happily these changes largely consist of new locations for things,
and additional pages.


Unsupported Operations
----------------------

The following features are missing and unlikely to return:

* The inline calandar.


Extending
---------

As mentioned the core code is pretty minimal and all output functionality
is carried out by plugins.

The core calls three methods, an all available plugins:

* `on_initiate`
   * This is called prior to any processing, with a reference to the configuration options and the database handle used for storage.
   * This is a good place to call code that generates common snippets, or populates global-variables.

* `modify_entry`
   * This method is invoked as a blog entry is read to disk before it is inserted into the database for the first time - or when the item on disk has been changed and the database must be refreshed.
   * This method is designed to handle Markdown/Textile conversion, etc.

* `on_terminate`
   * This is called after the database has been populated, again with a reference to the configuration options, and the database handle is provided.
   * This is where pages are output.

>**NOTE**: The names will probably change in the future.


Installation
-------------

Clone the repository then install as you would any CPAN module:

    perl Makefile.PL
    make test
    su - make install


Steve
--
