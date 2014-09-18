

clean:
	find . -name '*.bak' -delete

tidy:
	perltidy c2 $$(find -name '*.pm' -print)