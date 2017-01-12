#!/bin/sh

set -e # exit immediately upon error

heading() {
    echo "\n$1"
    echo "$1" | sed 's/./-/g'
}

section() {
    output=$($@)
    echo "$output" | sed 's/^/ /'
}

echo "Going to the sandbox"
cd $HOME/sandbox

heading "Creating hosts"
section "git init $HOME/sandbox/host-X.git --bare --template="
        "git init $HOME/sandbox/host-Z.git --bare --template="

section "ls -l"
exit

heading "Creating clients"
  git init $HOME/sandbox/client-A --template=
  cd $HOME/sandbox/client-A
  git config user.name client-A
  git init $HOME/sandbox/client-B --template=
  cd $HOME/sandbox/client-B
  git config user.name client-B

heading "Linking client-A to host-X, host-Z"
  cd $HOME/sandbox/client-A
  git remote add origin file://$HOME/sandbox/host-X.git
  git remote set-url --add --push origin file://$HOME/sandbox/host-X.git
  git remote set-url --add --push origin file://$HOME/sandbox/host-Z.git
  git remote -v

heading "Linking client-B to host-X"
  cd $HOME/sandbox/client-B
  git remote add origin file://$HOME/sandbox/host-X.git
  git remote -v

heading "client-A commits file_A"
  cd $HOME/sandbox/client-A
  echo 'file_A' > file_A
  git add file_A
  git commit -m 'file_A'

heading "client-A pushes file_A to host-X, host-Z"
  git push --set-upstream

heading "client-B pulls latest master from host-X"
  cd $HOME/sandbox/client-B
  git fetch origin master
  git merge origin/master
  git branch --set-upstream-to=origin/master

heading "client-b commits file_B"
  echo 'file_B' > file_B
  git add file_B
  git commit -m 'file_B'

heading "client-B pushes file_B to host-X"
  git push

heading "client-A commits file_A2"
  cd $HOME/sandbox/client-A
  echo 'file_A2' > file_A2
  git add file_A2
  git commit -m 'file_A2'

heading "client-A's git log:"
  git log --format=" %h %<(8)%s(%an)"

heading "host-X's git log:"
  cd $HOME/sandbox/host-X.git
  git log --format=" %h %<(8)%s(%an)"

heading "host-Z's git log:"
  cd $HOME/sandbox/host-Z.git
  git log --format=" %h %<(8)%s(%an)"

heading "client-A attempts to push without first pulling latest changes"
  cd $HOME/sandbox/client-A
  set +e # I know the following command will fail, but don't exit
  git push
  set -e

echo "\nNote that the push to host-X failed, but the push to host-Z succeeded."
echo "client-A will try to fix the situation by rebasing off upstream."

heading "client-A's git log BEFORE the rebase:"
  git log --format=" %h %<(8)%s(%an)"
  latest_sha1=$(git rev-parse --short HEAD)

echo "\nNote the latest commit, ${latest_sha1}, which added file_A2"

heading "client-A's working tree BEFORE the rebase:"
  ls -l

heading "client-A runs 'git pull --rebase'"
  git pull --rebase

heading "client-A's git log AFTER the rebase:"
  git log --format=" %h %<(8)%s(%an)"

heading "client-A's working tree AFTER the rebase:"
  ls -l

echo "\nWhat happened to file_A2?"
echo "We can recover it by cherry-picking ${latest_sha1},"
echo "but why wasn't it applied as part of the rebase?"
