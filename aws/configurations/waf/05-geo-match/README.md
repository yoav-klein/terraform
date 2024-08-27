# Geo Match
---


In this configuration, we create a Geo Match rule, which blocks access from Ireland and Israel.


## Usage
After creating the resources with `terrform apply`, run:


```
$ . test.sh
$ setup
```

Now try accessing from your browser (assuming you're in Israel) - and you see you're blocked.

If this machine is in ireland, running:
```
test
```

will also be blocked
