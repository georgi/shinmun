--- 
category: Ruby
guid: 72ece880-5e32-012b-362f-001a92975b89
date: 2008-09-01

Example post
============

This is the first paragraph. Below is a code example:

    # Return the first paragraph of rendered html.
    def summary
      body.split("\n\n")[0]
    end

    # Return the first paragraph of source text.
    def text_summary
      src.split("\n\n")[1]
    end
