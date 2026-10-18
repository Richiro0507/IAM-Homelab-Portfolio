# IAM Lab 02 — Screenshot Evidence Index

All images are from the completed simulated JML homelab on 2026-10-18. Employee identities and domain are fictional.

| Image | Phase | Evidence |
|---|---|---|
| [01-joiner-it-group-membership.png](screenshots/01-joiner-it-group-membership.png) | Joiner | Michael and Daniel in SG_IT_SUPPORT |
| [02-joiner-account-settings.png](screenshots/02-joiner-account-settings.png) | Joiner | Michael account settings and change password flag |
| [03-joiner-successful-login.png](screenshots/03-joiner-successful-login.png) | Joiner | Michael signed in to CLIENT01 |
| [04-joiner-it-share-read.png](screenshots/04-joiner-it-share-read.png) | Joiner | IT share open from client |
| [05-joiner-it-share-write.png](screenshots/05-joiner-it-share-write.png) | Joiner | Michael_Onboarding_Test.txt created on IT share |
| [06-joiner-file-content.png](screenshots/06-joiner-file-content.png) | Joiner | Saved onboarding text file opened in Notepad |
| [07-mover-finance-membership.png](screenshots/07-mover-finance-membership.png) | Mover | Sarah assigned to SG_FINANCE |
| [08-mover-finance-ntfs.png](screenshots/08-mover-finance-ntfs.png) | Mover | SG_FINANCE Modify NTFS permission |
| [09-mover-finance-share-admin.png](screenshots/09-mover-finance-share-admin.png) | Mover | Share administrators Full Control |
| [10-mover-finance-share-group.png](screenshots/10-mover-finance-share-group.png) | Mover | SG_FINANCE Change and Read share permissions |
| [11-mover-sarah-finance-allowed.png](screenshots/11-mover-sarah-finance-allowed.png) | Mover | Finance share opens for Sarah |
| [12-mover-michael-finance-denied-baseline.png](screenshots/12-mover-michael-finance-denied-baseline.png) | Mover | Michael denied Finance share before transfer |
| [13-mover-finance-ou.png](screenshots/13-mover-finance-ou.png) | Mover | Michael moved to Finance OU |
| [14-mover-old-it-membership.png](screenshots/14-mover-old-it-membership.png) | Mover | Michael retains SG_IT_SUPPORT after OU transfer |
| [15-mover-it-access-creep.png](screenshots/15-mover-it-access-creep.png) | Mover | Michael still opens IT share after transfer |
| [16-mover-overlapping-groups.png](screenshots/16-mover-overlapping-groups.png) | Mover | Michael temporarily belongs to both groups |
| [17-mover-it-denied-after-revocation.png](screenshots/17-mover-it-denied-after-revocation.png) | Mover | IT share access denied following remediation |
| [18-mover-finance-allowed-after-transfer.png](screenshots/18-mover-finance-allowed-after-transfer.png) | Mover | Finance share opens following transfer |
| [19-mover-final-finance-only-membership.png](screenshots/19-mover-final-finance-only-membership.png) | Mover | Final Domain Users and SG_FINANCE membership |
| [20-leaver-account-disabled.png](screenshots/20-leaver-account-disabled.png) | Leaver | ADUC confirms Michael account disabled |
| [21-leaver-final-groups.png](screenshots/21-leaver-final-groups.png) | Leaver | Member Of only Domain Users |
| [22-leaver-login-blocked.png](screenshots/22-leaver-login-blocked.png) | Leaver | Disabled-account sign-in error |
| [23-leaver-powershell-verification.png](screenshots/23-leaver-powershell-verification.png) | Leaver | Get-ADUser Enabled False MemberOf empty |

## Ready-to-paste Markdown gallery

Copy this section into the **end** of your Lab 2 `README.md` once you have extracted the `screenshots` folder into your Lab 2 project directory.

```markdown
## Screenshot Evidence

### Joiner: Michael and Daniel in SG_IT_SUPPORT
![Michael and Daniel in SG_IT_SUPPORT](screenshots/01-joiner-it-group-membership.png)

### Joiner: Michael account settings and change password flag
![Michael account settings and change password flag](screenshots/02-joiner-account-settings.png)

### Joiner: Michael signed in to CLIENT01
![Michael signed in to CLIENT01](screenshots/03-joiner-successful-login.png)

### Joiner: IT share open from client
![IT share open from client](screenshots/04-joiner-it-share-read.png)

### Joiner: Michael_Onboarding_Test.txt created on IT share
![Michael_Onboarding_Test.txt created on IT share](screenshots/05-joiner-it-share-write.png)

### Joiner: Saved onboarding text file opened in Notepad
![Saved onboarding text file opened in Notepad](screenshots/06-joiner-file-content.png)

### Mover: Sarah assigned to SG_FINANCE
![Sarah assigned to SG_FINANCE](screenshots/07-mover-finance-membership.png)

### Mover: SG_FINANCE Modify NTFS permission
![SG_FINANCE Modify NTFS permission](screenshots/08-mover-finance-ntfs.png)

### Mover: Share administrators Full Control
![Share administrators Full Control](screenshots/09-mover-finance-share-admin.png)

### Mover: SG_FINANCE Change and Read share permissions
![SG_FINANCE Change and Read share permissions](screenshots/10-mover-finance-share-group.png)

### Mover: Finance share opens for Sarah
![Finance share opens for Sarah](screenshots/11-mover-sarah-finance-allowed.png)

### Mover: Michael denied Finance share before transfer
![Michael denied Finance share before transfer](screenshots/12-mover-michael-finance-denied-baseline.png)

### Mover: Michael moved to Finance OU
![Michael moved to Finance OU](screenshots/13-mover-finance-ou.png)

### Mover: Michael retains SG_IT_SUPPORT after OU transfer
![Michael retains SG_IT_SUPPORT after OU transfer](screenshots/14-mover-old-it-membership.png)

### Mover: Michael still opens IT share after transfer
![Michael still opens IT share after transfer](screenshots/15-mover-it-access-creep.png)

### Mover: Michael temporarily belongs to both groups
![Michael temporarily belongs to both groups](screenshots/16-mover-overlapping-groups.png)

### Mover: IT share access denied following remediation
![IT share access denied following remediation](screenshots/17-mover-it-denied-after-revocation.png)

### Mover: Finance share opens following transfer
![Finance share opens following transfer](screenshots/18-mover-finance-allowed-after-transfer.png)

### Mover: Final Domain Users and SG_FINANCE membership
![Final Domain Users and SG_FINANCE membership](screenshots/19-mover-final-finance-only-membership.png)

### Leaver: ADUC confirms Michael account disabled
![ADUC confirms Michael account disabled](screenshots/20-leaver-account-disabled.png)

### Leaver: Member Of only Domain Users
![Member Of only Domain Users](screenshots/21-leaver-final-groups.png)

### Leaver: Disabled-account sign-in error
![Disabled-account sign-in error](screenshots/22-leaver-login-blocked.png)

### Leaver: Get-ADUser Enabled False MemberOf empty
![Get-ADUser Enabled False MemberOf empty](screenshots/23-leaver-powershell-verification.png)

```

## Public repository review

Before publishing, review every screenshot for sensitive data, host paths, account identities, credentials, tokens, and unrelated desktop details. Only publish lab-only details. These screenshots are not evidence of a production deployment.
