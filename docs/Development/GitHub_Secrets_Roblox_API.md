# GitHub Secrets

For the GitHub actions to work properly we need to add some evironment vars with valid Roblox API keys.

### Create Roblox API keys

1. Head to https://create.roblox.com/
1. In the left navbar: _All Tools -> API Keys_
1. Choose: _Create API Key_
1. Name it: eg "My Project - GitHub Actions"
1. Under _Access permissions_ grant the following:
    - asset:read
    - legacy-asset:manage
1. Under _Security_ ensure "Restrict IPs" is **not** enabled
1. Under _Security_ set an expiration date. Good practice to rotate keys every now and then.
1. Choose _Save & Generate Key_
1. Choose _Copy Key To Clipboard_ - you will not be shown the key again.

### Add GitHub Environment Secret

1. Head to your GitHub repository
1. Go to _Settings -> Secrets and variables -> Actions_
1. Choose _New respository secret_
1. In the _Name_ field enter `USER_API_KEY`
1. In the _Secret_ field paste the key from your clipboard
1. Choose _Add secret_

### Update Action permissions

1. Head to your GitHub repository
1. Go to _Settings -> Actions -> General_
1. Under _Workflow permissions_ enable _Read and write permissions_
1. Choose _Save_
