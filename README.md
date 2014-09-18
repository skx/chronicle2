c2
--

c2 is a proof of concept replacement for the [chronicle blog compiler](http://www.steve.org.uk/Software/chronicle/).


Differences
-----------

The biggest difference is the use of SQLite ...

Other differences:

* Themese are installed globally via the Module::Maker
* Plugins are used extensively.
   * Even more so once this is done
* (Minimal) test-cases
* Designed to install like a CPAN module
* Significantly faster generation


User Visible Changes
--------------------

Should be none:

* Entries are still read from `data/`
* Entries are still written to `output/`
* Template data has changed, but Steve will reinsert the stock templates and make them work.




This readme is a stub.  Look at the top of `c2` for more details.
