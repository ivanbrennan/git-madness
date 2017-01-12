This is an attempt to reproduce and debug add odd Git scenario I've run into a couple
times.

    Going to the sandbox

    Creating hosts
    --------------
    Initialized empty Git repository in /Users/ivan/sandbox/host-X.git/
    Initialized empty Git repository in /Users/ivan/sandbox/host-Z.git/

    Creating clients
    ----------------
    Initialized empty Git repository in /Users/ivan/sandbox/client-A/.git/
    Initialized empty Git repository in /Users/ivan/sandbox/client-B/.git/

    Linking client-A to host-X, host-Z
    ----------------------------------
    origin	file:///Users/ivan/sandbox/host-X.git (fetch)
    origin	file:///Users/ivan/sandbox/host-X.git (push)
    origin	file:///Users/ivan/sandbox/host-Z.git (push)

    Linking client-B to host-X
    --------------------------
    origin	file:///Users/ivan/sandbox/host-X.git (fetch)
    origin	file:///Users/ivan/sandbox/host-X.git (push)

    client-A commits file_A
    -----------------------
    [master (root-commit) 7b1de92] file_A
     1 file changed, 1 insertion(+)
     create mode 100644 file_A

    client-A pushes file_A to host-X, host-Z
    ----------------------------------------
    Counting objects: 3, done.
    Writing objects: 100% (3/3), 213 bytes | 0 bytes/s, done.
    Total 3 (delta 0), reused 0 (delta 0)
    To file:///Users/ivan/sandbox/host-X.git
     * [new branch]      master -> master
    Branch master set up to track remote branch master from origin.
    Counting objects: 3, done.
    Writing objects: 100% (3/3), 213 bytes | 0 bytes/s, done.
    Total 3 (delta 0), reused 0 (delta 0)
    To file:///Users/ivan/sandbox/host-Z.git
     * [new branch]      master -> master
    Branch master set up to track remote branch master from origin.

    client-B pulls latest master from host-X
    ----------------------------------------
    remote: Counting objects: 3, done.
    remote: Total 3 (delta 0), reused 0 (delta 0)
    Unpacking objects: 100% (3/3), done.
    From file:///Users/ivan/sandbox/host-X
     * branch            master     -> FETCH_HEAD
     * [new branch]      master     -> origin/master
    Branch master set up to track remote branch master from origin.

    client-b commits file_B
    -----------------------
    [master aba12d4] file_B
     1 file changed, 1 insertion(+)
     create mode 100644 file_B

    client-B pushes file_B to host-X
    --------------------------------
    Counting objects: 3, done.
    Delta compression using up to 4 threads.
    Compressing objects: 100% (2/2), done.
    Writing objects: 100% (3/3), 269 bytes | 0 bytes/s, done.
    Total 3 (delta 0), reused 0 (delta 0)
    To file:///Users/ivan/sandbox/host-X.git
       7b1de92..aba12d4  master -> master

    client-A commits file_A2
    ------------------------
    [master 8a17283] file_A2
     1 file changed, 1 insertion(+)
     create mode 100644 file_A2

    client-A's git log:
    -------------------
     8a17283 file_A2 (client-A)
     7b1de92 file_A  (client-A)

    host-X's git log:
    -----------------
     aba12d4 file_B  (client-B)
     7b1de92 file_A  (client-A)

    host-Z's git log:
    -----------------
     7b1de92 file_A  (client-A)

    client-A attempts to push without first pulling latest changes
    --------------------------------------------------------------
    To file:///Users/ivan/sandbox/host-X.git
     ! [rejected]        master -> master (fetch first)
    error: failed to push some refs to 'file:///Users/ivan/sandbox/host-X.git'
    hint: Updates were rejected because the remote contains work that you do
    hint: not have locally. This is usually caused by another repository pushing
    hint: to the same ref. You may want to first integrate the remote changes
    hint: (e.g., 'git pull ...') before pushing again.
    hint: See the 'Note about fast-forwards' in 'git push --help' for details.
    Counting objects: 3, done.
    Delta compression using up to 4 threads.
    Compressing objects: 100% (2/2), done.
    Writing objects: 100% (3/3), 271 bytes | 0 bytes/s, done.
    Total 3 (delta 0), reused 0 (delta 0)
    To file:///Users/ivan/sandbox/host-Z.git
       7b1de92..8a17283  master -> master

    Note that the push to host-X failed, but the push to host-Z succeeded.
    client-A will try to fix the situation by rebasing off upstream.

    client-A's git log BEFORE the rebase:
    -------------------------------------
     8a17283 file_A2 (client-A)
     7b1de92 file_A  (client-A)

    Note the latest commit, 8a17283, which added file_A2

    client-A's working tree BEFORE the rebase:
    ------------------------------------------
    total 16
    -rw-r--r--  1 ivan  staff  7 Jan 12 16:44 file_A
    -rw-r--r--  1 ivan  staff  8 Jan 12 16:44 file_A2

    client-A runs 'git pull --rebase'
    ---------------------------------
    remote: Counting objects: 3, done.
    remote: Compressing objects: 100% (2/2), done.
    remote: Total 3 (delta 0), reused 0 (delta 0)
    Unpacking objects: 100% (3/3), done.
    From file:///Users/ivan/sandbox/host-X
     + 8a17283...aba12d4 master     -> origin/master  (forced update)
    First, rewinding head to replay your work on top of it...

    client-A's git log AFTER the rebase:
    ------------------------------------
     aba12d4 file_B  (client-B)
     7b1de92 file_A  (client-A)

    client-A's working tree AFTER the rebase:
    -----------------------------------------
    total 16
    -rw-r--r--  1 ivan  staff  7 Jan 12 16:44 file_A
    -rw-r--r--  1 ivan  staff  7 Jan 12 16:44 file_B

    What happened to file_A2?
    We can recover it by cherry-picking 8a17283,
    but why wasn't it applied as part of the rebase?
