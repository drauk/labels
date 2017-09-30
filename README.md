# labels
Some slanting labels made with MetaPost.

This demonstrates how to create certain kinds of labels with MetaPost using a Perl script. It's an extremely specific technique which probably is of little use to most people.

To run this software, you need make, perl, mpost, tex, dvips, ps2pdf.

To create the example output files "label3.pdf" and "label4.pdf", type "make -f makefile.pub filename.pdf", where filename is "label3" or "label4". Then you can do the same sort of thing with any 22-line text file.

If the string "<<<" appears in a column label, this is interpreted as a newline, which causes the text to be split into two rows.
