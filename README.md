# labels
Some oblique labels made with MetaPost.

This demonstrates how to create certain kinds of labels with MetaPost using a Perl script. It's an extremely specific technique which probably is of little use to most people.

To run this software, you need make, perl, mpost, tex, dvips, ps2pdf.

To create the example output files "label3.pdf" and "label4.pdf", type "make -f makefile.pub filename.pdf", where filename is "label3" or "label4". Then you can do the same sort of thing with any 22-line text file.

If the string "<<<" appears in a column label, this is interpreted as a newline, which causes the text to be split into two rows.

If the string "%%%" appears at the beginning of a line in the txt input file, followed by space, the line will not appear on the label in the output. It is interpreted as either a comment or a command. At present, the only command is "darkness" or "dark", case-independent. The darkness-percentage of the dark columns in the output is the expected parameter. Thus for example:

    %%% Darkness 10

will cause the dark columns to have 10% darkness in the ouput PDF file, which means that the whiteness-parameter is set to 90%.

To choose the TFM font to use for the labels, use the command "font" (case-insensitive) like as follows in the txt input file.

    %%% FONT phvr8rn

Then if you are lucky, there might be a suitable TeX font which makes this work. (I still can't figure out which fonts work without a lot of trial-and-error.)
