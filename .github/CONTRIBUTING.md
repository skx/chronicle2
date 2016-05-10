= Quick Checklist =

I welcome the submission of additional features, and improvements to
the codebase.  This template-file contains just a few last minute checks
to complete before you submit your pull-request:

[ ] Did you run the test-cases?
    - If you did, great!

[ ] Did you add any new modules?
    - If so please remember to make sure your name is listed as the AUTHOR.
    - Don't forget to write the documentation, at the top of the module.

[ ] Did you reformat the code?
    - There is a `.perltidyrc` file in the repository, so just run this:
        perltidy $(find . -name '*.pm')
