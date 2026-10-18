\# Lab 02 — Joiner, Mover, Leaver (JML) Identity Lifecycle Management



\*\*Status:\*\* Completed

\*\*Environment:\*\* Windows Server 2025, Windows 11 Enterprise, Oracle VirtualBox

\*\*Focus:\*\* Identity Provisioning, RBAC, Access Reviews, Access Creep, Offboarding



\## Project Overview



This project demonstrates the Joiner–Mover–Leaver (JML) identity lifecycle in a simulated enterprise environment.



The objective was to provision a new employee, manage a department transfer, investigate excessive permissions, and securely disable an employee identity during offboarding.



All activities were performed in an isolated Active Directory homelab.



\## Lab Environment



| Component | Configuration |

|---|---|

| Domain Controller | DC01 — Windows Server 2025 |

| Client Workstation | CLIENT01 — Windows 11 Enterprise |

| Domain | corp.example.test |

| Hypervisor | Oracle VirtualBox |

| Network | CORP-LAN |

| Directory Service | Active Directory Domain Services |



\## Phase 1 — Joiner: Employee Onboarding



\### Scenario



Michael Thompson joins Rodriguez Technologies as an IT Support Specialist.



\### Actions Performed



1\. Created the Active Directory account michael.thompson.

2\. Placed the account in the IT organizational unit.

3\. Assigned membership to SG\_IT\_SUPPORT.

4\. Configured a temporary password requiring a change at first sign-in.

5\. Signed in to CLIENT01 using Michael's domain account.

6\. Verified access to the restricted IT network share.

7\. Created and saved a text file to validate write permissions.



\### Validation



Michael successfully authenticated and created Michael\_Onboarding\_Test.txt inside the IT shared folder.



\*\*Result:\*\* Onboarding access validation passed.



\## Phase 2 — Mover: Department Transfer



\### Scenario



Michael transfers from IT to Finance.



The transfer requires granting Finance access and removing IT permissions.



\### Actions Performed



1\. Created the SG\_FINANCE security group.

2\. Added Sarah Johnson, an existing Finance employee.

3\. Created the C:\\Finance\_Files directory.

4\. Configured NTFS permissions allowing SG\_FINANCE Modify access.

5\. Configured SMB share permissions allowing SG\_FINANCE Change and Read access.

6\. Verified Sarah could access the Finance share.

7\. Verified Michael initially could not access the Finance share.

8\. Moved Michael's Active Directory account from the IT OU to the Finance OU.

9\. Reviewed Michael's existing security group memberships.



\### Access Creep Finding



After transferring Michael's account to the Finance OU, his SG\_IT\_SUPPORT membership remained active.



Michael could still access restricted IT resources despite no longer working in that department.



This demonstrated access creep caused by incomplete entitlement removal during a department transfer.



\### Remediation



1\. Added Michael to SG\_FINANCE.

2\. Removed Michael from SG\_IT\_SUPPORT.

3\. Refreshed his Windows logon session.

4\. Retested access to both departmental shares.

5\. Confirmed his final security group memberships.



\### Validation Results



| Resource | Before Transfer | After Remediation |

|---|---|---|

| IT Support share | Allowed | Denied |

| Finance share | Denied | Allowed |



Michael's final group memberships were Domain Users and SG\_FINANCE.



\*\*Result:\*\* Department transfer and access creep remediation passed.



\## Phase 3 — Leaver: Employee Offboarding



\### Scenario



Michael's employment is terminated. The approved offboarding request requires disabling his account and removing departmental access.



\### Actions Performed



1\. Disabled Michael's Active Directory user account.

2\. Removed his SG\_FINANCE security group membership.

3\. Confirmed only his primary Domain Users group remained.

4\. Attempted a new Windows domain sign-in using Michael's disabled account.

5\. Verified that Windows rejected the sign-in.

6\. Ran PowerShell to validate the account state and group memberships.



\### PowerShell Verification



\~\~\~powershell

Get-ADUser -Identity michael.thompson -Properties Enabled,MemberOf |

&#x20;   Select-Object Name,SamAccountName,Enabled,MemberOf

\~\~\~



\### PowerShell Results



| Property | Result |

|---|---|

| Name | Michael Thompson |

| SamAccountName | michael.thompson |

| Enabled | False |

| MemberOf | {} |



The MemberOf attribute does not include the user's primary group.



Windows displayed a message indicating that the account had been disabled.



\*\*Result:\*\* Active Directory offboarding validation passed.



\## Security Concepts Demonstrated



\- Identity lifecycle management

\- Account provisioning and deprovisioning

\- Departmental access assignments

\- Role-based access control

\- Principle of least privilege

\- Access creep identification

\- Entitlement revocation

\- Access reviews

\- Authentication validation

\- PowerShell-based Active Directory verification



\## Lessons Learned



Moving an Active Directory account between organizational units does not automatically update its security group memberships.



Incomplete offboarding or department transfers can leave unnecessary permissions assigned to employee identities.



Effective IAM processes require verification of both authorized access and revoked access.



Disabling an account prevents new domain authentication, but production offboarding should also address active sessions, application access, cloud identities, and other credentials.



\## Lab Disclaimer



This project was completed in an isolated personal homelab using fictional employee identities. The scenarios and access requests were simulated for educational purposes. No production systems were involved.



```markdown

\## Screenshot Evidence



\### Joiner: Michael and Daniel in SG\_IT\_SUPPORT

!\[Michael and Daniel in SG\_IT\_SUPPORT](screenshots/01-joiner-it-group-membership.png)



\### Joiner: Michael account settings and change password flag

!\[Michael account settings and change password flag](screenshots/02-joiner-account-settings.png)



\### Joiner: Michael signed in to CLIENT01

!\[Michael signed in to CLIENT01](screenshots/03-joiner-successful-login.png)



\### Joiner: IT share open from client

!\[IT share open from client](screenshots/04-joiner-it-share-read.png)



\### Joiner: Michael\_Onboarding\_Test.txt created on IT share

!\[Michael\_Onboarding\_Test.txt created on IT share](screenshots/05-joiner-it-share-write.png)



\### Joiner: Saved onboarding text file opened in Notepad

!\[Saved onboarding text file opened in Notepad](screenshots/06-joiner-file-content.png)



\### Mover: Sarah assigned to SG\_FINANCE

!\[Sarah assigned to SG\_FINANCE](screenshots/07-mover-finance-membership.png)



\### Mover: SG\_FINANCE Modify NTFS permission

!\[SG\_FINANCE Modify NTFS permission](screenshots/08-mover-finance-ntfs.png)



\### Mover: Share administrators Full Control

!\[Share administrators Full Control](screenshots/09-mover-finance-share-admin.png)



\### Mover: SG\_FINANCE Change and Read share permissions

!\[SG\_FINANCE Change and Read share permissions](screenshots/10-mover-finance-share-group.png)



\### Mover: Finance share opens for Sarah

!\[Finance share opens for Sarah](screenshots/11-mover-sarah-finance-allowed.png)



\### Mover: Michael denied Finance share before transfer

!\[Michael denied Finance share before transfer](screenshots/12-mover-michael-finance-denied-baseline.png)



\### Mover: Michael moved to Finance OU

!\[Michael moved to Finance OU](screenshots/13-mover-finance-ou.png)



\### Mover: Michael retains SG\_IT\_SUPPORT after OU transfer

!\[Michael retains SG\_IT\_SUPPORT after OU transfer](screenshots/14-mover-old-it-membership.png)



\### Mover: Michael still opens IT share after transfer

!\[Michael still opens IT share after transfer](screenshots/15-mover-it-access-creep.png)



\### Mover: Michael temporarily belongs to both groups

!\[Michael temporarily belongs to both groups](screenshots/16-mover-overlapping-groups.png)



\### Mover: IT share access denied following remediation

!\[IT share access denied following remediation](screenshots/17-mover-it-denied-after-revocation.png)



\### Mover: Finance share opens following transfer

!\[Finance share opens following transfer](screenshots/18-mover-finance-allowed-after-transfer.png)



\### Mover: Final Domain Users and SG\_FINANCE membership

!\[Final Domain Users and SG\_FINANCE membership](screenshots/19-mover-final-finance-only-membership.png)



\### Leaver: ADUC confirms Michael account disabled

!\[ADUC confirms Michael account disabled](screenshots/20-leaver-account-disabled.png)



\### Leaver: Member Of only Domain Users

!\[Member Of only Domain Users](screenshots/21-leaver-final-groups.png)



\### Leaver: Disabled-account sign-in error

!\[Disabled-account sign-in error](screenshots/22-leaver-login-blocked.png)



\### Leaver: Get-ADUser Enabled False MemberOf empty

!\[Get-ADUser Enabled False MemberOf empty](screenshots/23-leaver-powershell-verification.png)

