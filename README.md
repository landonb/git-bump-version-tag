# git-bump-version-tag

Glorified wrapper around essentially the 2-command sequence:

  ```shell
  git tag -a <version> -m "Version: <version>"
  git push <remote> <branch> "refs/tags/<version>"
  ```

Keeps you from figuring out the version yourself and typing, say:

  ```shell
  git tag -a "1.2.3" -m "Version: 1.2.3"
  git push origin master "refs/tags/1.2.3"
  ```

This command adds error and sanity checking,
and lets you specify which version part to bump.

Use case: To support rapid development and encourage frequent versioning.

## Usage

If the project has no version tags, "0.0.0" is assumed, so it's easier
to get started.

- A bare command increments the patch level.

  For an unversioned project, this starts the repository at version 0.0.1.

  For instance, assuming you alias `bump` to `bump-version-tag`, for brevity,
  then:

    ```shell
    $ git bump
    Please Yes/no/skip: Ready to bump “0.0.1”? [Y/n/s]
    ```

  Press `Y` or `y` followed by Enter to tag the HEAD of the current branch.

  To skip the operation, press `s` or `S` instead, followed by Enter,
  and the tool will proceed to the git-push operation.

  Any other input (like `N` or `n`) kills the script.

  But suppose you answer "yes", then the command will use `ls-remote`
  to query the remote, to see if the tag had been pushed already.
  If the tag is not pushed, the script will confirm that you want
  to push the tag (which will include any necessary commits).
  E.g.,

    ```shell
    $ git bump
    Please Yes/no/skip: Ready to bump “0.0.1”? [Y/n/s] y
    Network call: ‘git ls-remote --tags origin 0.0.1’...
    Please Yes/no/skip: Ready to push “0.0.1”? [Y/n/s] y
    Counting objects: 58, done.
    Delta compression using up to 8 threads.
    Compressing objects: 100% (58/58), done.
    Writing objects: 100% (58/58), 9.03 KiB | 1.13 MiB/s, done.
    Total 58 (delta 40), reused 0 (delta 0)
    remote: Resolving deltas: 100% (40/40), completed with 14 local objects.
    git log
    To github.com:landonb/git-bump-version-tag.git
       0834e71..4a10078  master -> master
     * [new tag]         0.0.1 -> 0.0.1
    ```

- You can instead specify the version part to increment.

  The recognized parts are: `M|major`, `m|minor`, `p|patch`, and `a|alpha`.

  For instance, suppose the version is 0.0.1, then:

    ```
    $ git bump M
    Please Yes/no/skip: Okay to bump “0.0.1” → “1.0.0”? [Y/n/s]
    ```

  When starting alpha versioning, the tool knowingly bumps the patch
  number, too, per semantic versioning specs, e.g.,

    ```
    $ git bump a
    Please Yes/no/skip: Okay to bump “0.0.1” → “0.0.2a1”? [Y/n/s]
    ```

  because "0.0.1" > "0.0.1a1".

- There's also a special `s|same` specifier that you can use when
  HEAD is versioned, to tell the tool to skip git-tag and proceed
  to git-push.

    ```
    $ git bump s
    Network call: ‘git ls-remote --tags origin 0.0.1’...
    ```

- Finally, you can specify the version explicitly.
  E.g.:

    ```
    $ git bump 3.1.4
    Please Yes/no/skip: Okay to bump “0.0.1” → “3.1.4”? [Y/n/s]
    ```

## Prerequisites

This git command relies on a Python command,
[`pep440cmp`](https://pypi.org/project/pep440-version-compare-cli/),
available from the Python Packing Index (PyPI).

- To install locally, you can simply run pip (or more likely pip3), e.g.,

    ```shell
    pip3 install pep440-version-compare-cli
    ```

  Or run the same command as superuser to install globally.

- If you'd like to isolate the application, install to a
  [virtual environment](https://virtualenv.pypa.io/en/latest/)
  (after installing
  [virtualenvwrapper](https://pypi.org/project/virtualenvwrapper/)), e.g.,

    ```shell
    $ mkvirtualenv git-bump
    (git-bump) $ pip install pep440-version-compare-cli
    ```

  Remember, if you use a virtual environemtn, you'll have to load
  the "venv" before you can use this command, e.g.,

    ```shell
    $ workon git-bump
    (git-bump) $ git bump p
    ```

## Setup

Choose from one of the following setup options, or go your own way.

1. You could clone this project and wire the `bin/` to your user's `PATH`.
   For instance:

      ```shell
      # Clone this repo somewhere.
      git clone https://github.com/landonb/git-bump-version-tag.git
      # Add its bin/ path to PATH. Something like this:
      echo 'export PATH="'$(pwd)'/git-bump-version-tag/bin:${PATH}"' >> ~/.bashrc
      ```

2. You could clone this project and symlink the included command from
   a directory that's already on `PATH`. E.g., if `~/.local/bin` is
   already on the user's path, you could clone the repository and then
   symlink the executable:

      ```shell
      # Clone this repo somewhere.
      git clone https://github.com/landonb/git-bump-version-tag.git
      # Add a symlink to the git subcommand. say:
      cmdpath="$(pwd)/git-bump-version-tag/bin/git-bump-version-tag"
      /bin/ln -s "${cmdpath}" ~/.local/bin/
      # Or, if you wanted to wire it to `git bump` instead, try:
      /bin/ln -s "${cmdpath}" ~/.local/bin/git-bump
      ```

3. You could clone this project and update your `~/.gitconfig` with the path
   to the executable. For instance:

      ```shell
      # Clone this repo somewhere.
      git clone https://github.com/landonb/git-bump-version-tag.git
      # Add the command to ~/.gitconfig, like this:
      cmdpath="$(pwd)/git-bump-version-tag/bin/git-bump-version-tag"
      echo -e '[alias]\n  bump = !"'${cmdpath}'"' >> ~/.gitconfig
      ```

## Compares to

- Related projects:

  https://github.com/mpalmer/git-version-bump —
  A Ruby project that bumps Git version tags.

  https://github.com/c4urself/bump2version/ —
  A Python project that bumps version strings in files.

This project is most similar to the Ruby project,
``git-version-bump``, with the following differences:
- This project is pure Bash (it could be POSIX except for array usage);
- This project performs error- and sanity-checking;
- This project supports bumping the alpha part; and
- This project calls git-push.

