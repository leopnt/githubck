# Githubck

Script I use to backup my github repos

## Encrypt token with password
this is useful if someone get access to your machine. So that your github token is not written
in plain text file.

0) make a github token in `settings > developer settings > personal access token` and give full repo access

1) write token into file
```
echo "<ghub_token_here>" > ghub_token.txt
```
**Make sure to remove the last line that contains the token from `~/.bash_history`**

or disable your shell's history while doing the previous task

2) encrypt token

It will ask for a password. Remember this password for the github script
```
gpg -o ghub_token.gpg --symmetric --no-symkey-cache ghub_token.txt
```

3) check decryption
```
gpg --no-symkey-cache --quiet -d --batch --passphrase "<step 2 password>" ghub_token.gpg
```

4) execute script
 
on macos:
```
bash -i ./github_backup.sh -d <backup destination folder>
```

It will ask for username and the token encryption password

## Example output after backups
```
backup_folder
  |-- 2021-11-20T142548.tar.gz
    |-- repo1
    |-- repo2
    ...
  |-- 2021-11-22T000023.tar.gz
  |-- 2021-11-23T000023.tar.gz
  ...
```
