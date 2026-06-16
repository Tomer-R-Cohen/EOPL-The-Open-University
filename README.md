# EOPL Setup Guide

## Requirements

- Windows PC
- [Racket](https://racket-lang.org) (latest version)
- [VS Code](https://code.visualstudio.com)

---

## Step 1 — Install Racket

1. Download the latest Racket installer from `racket-lang.org`
2. During installation, change the path to `C:\Users\YOUR_NAME\Racket\` to avoid permission issues

---

## Step 2 — Add Racket to PATH

1. Search **"environment variables"** in the start menu
2. Click **"Edit the system environment variables"**
3. Click **"Environment Variables"**
4. Under **System variables**, find **Path** and click **Edit**
5. Click **New** and add `C:\Program Files\Racket\` (or wherever you installed it)
6. Click OK on everything
7. Reopen PowerShell

Test it works by typing:

```
racket --version
```

---

## Step 3 — Install VS Code + Magic Racket

1. Download VS Code from `code.visualstudio.com`
2. Open VS Code → Extensions (`Ctrl+Shift+X`)
3. Search **Magic Racket Student Language** and install it
4. In PowerShell, run:

```
cd "C:\Program Files\Racket" (or wherever you installed it)
.\raco pkg install racket-langserver
and press Y when asked to install all additional dependencies for the package
```

---y

## Step 4 — Fix Compatibility Issue in EOPL Files

The EOPL source files use old syntax that doesn't work with newer Racket.

In any file that contains:

```scheme
(provide (all-defined))
```

Change it to:

```scheme
(provide (all-defined-out))
```

---

## Step 5 — Running the Interpreter

To run an EOPL interpreter file, use the `-i` and `-t` flags to keep the REPL open:

```powershell
racket -i -t 'path/to/top.scm'
```

You'll get a `>` prompt. Then you can run programs like:

```scheme
(run "let x = 5 in -(x, 3)")
(run "let x = 7 in let y = 2 in -(x, y)")
(run "if zero?(0) then 1 else 2")
```

---

## Notes

- The `-i` flag keeps the REPL open after loading the file
- The `-t` flag loads the file before starting the REPL
- Without `-i`, the file runs and exits immediately
