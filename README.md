mailbot
=======


## Installation

```
git clone git@github.com:adjust/mailbot.git
cd mailbot && perl Build.PL
./Build installdeps
```

## Configuration

In order to configure mailbot, just edit the `config.yml` file.

## Usage

```
perl bin/main.pl
```

## What does it do?
It will connect to the account specified in the `config.yml` file.
It will search the inbox 'INBOX' for *unread* mails.
If the `From` field matches the entry `allowedSender` from the `config.yml`
it will search for an adjust report url and download the report and print it to
standard out. Every mail it finds will be set to `seen`.
