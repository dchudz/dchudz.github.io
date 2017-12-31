---
layout: post
category: posts
draft: false
title: Regexes for replacing ugly unittest-style assertions
---

In case they help anyone else, here are some regular expressions I used once to convert some ugly unittest-style assertions (e.g. `self.assertEqual(something, something_else)` to the pytest style (simply `assert something == something_else`):
	
```
sed -i ".bak" -E 's/self\.assertFalse\((.*)\)/assert not \1/g' tests/*.py
sed -i ".bak" -E 's/self\.assertTrue\((.*)\)/assert \1/g' tests/*.py
sed -i ".bak" -E 's/self\.assertEqual\(([^,]*), (.*)\)$/assert \1 == \2/g' tests/*.py
sed -i ".bak" -E 's/self\.assertIn\(([^,]*), (.*)\)$/assert \1 in \2/g' tests/*.py
sed -i ".bak" -E 's/self\.assertNotEqual\(([^,]*), (.*)\)$/assert \1 != \2/g' tests/*.py
sed -i ".bak" -E 's/self\.assertNotIn\(([^,]*), (.*)\)$/assert \1 not in \2/g' tests/*.py
sed -i ".bak" -E 's/self\.assertIsNone\((.*)\)$/assert \1 is None/g' tests/*.py
sed -i ".bak" -E 's/self\.assertIsNotNone\((.*)\)$/assert \1 is not None/g' tests/*.py
```

(Pytest gives nice informative error messages even if you just use the prettier form.)

Note:

- The option `-i` means "do it in-place" (modify the file). Including `".bak"` means "make backups of the old version with this extension".
- I don't actually want the backups, but (for some odd reason) on my Mac, not asking for them changed how the regex was interpreted to something that's not right.
- After reviewing and checking in the changes I wanted, I cleaned up the backups with `git clean -f` (careful you don't have any unchecked-in changes you want to keep!).