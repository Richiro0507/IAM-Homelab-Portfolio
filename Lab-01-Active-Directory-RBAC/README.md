\# Lab 01 — Active Directory \& Role-Based Access Control (RBAC)



\*\*Status:\*\* Completed  

\*\*Environment:\*\* Windows Server 2025, Windows 11 Enterprise, Oracle VirtualBox  

\*\*Focus:\*\* Identity Administration, Access Control, Least Privilege, IAM Security



\## Project Overview



This project demonstrates the deployment and administration of an Active Directory environment, implementation of role-based access controls, and investigation of a simulated unauthorized-access incident.



The objective was to understand how identities, security groups, and file permissions interact to control access to enterprise resources.



\## Lab Architecture



| Component | Configuration |

|---|---|

| Hypervisor | Oracle VirtualBox |

| Domain Controller | DC01 — Windows Server 2025 |

| Client Workstation | CLIENT01 — Windows 11 Enterprise |

| Domain | corp.example.test |

| Network | CORP-LAN (isolated internal network) |

| DC01 IP | 192.168.50.10 |

| CLIENT01 IP | 192.168.50.20 |

| DNS Server | 192.168.50.10 |



\## Active Directory Configuration



Created an organizational structure under `RodriguezTechnologies` containing:



\- IT

\- Finance

\- Human Resources

\- Operations



Provisioned fictional employee identities:



\- Daniel Martinez — IT

\- Sarah Johnson — Finance



Created the `SG\_IT\_SUPPORT` global security group to manage access to restricted IT resources.



\## Role-Based Access Control



Configured the following resource:



`\\\\DC01\\IT\_Support\_Files`



Applied NTFS and SMB share permissions so that:



\- `SG\_IT\_SUPPORT` members received appropriate read/write access.

\- Administrators retained administrative access.

\- Unauthorized users were excluded from the restricted resource.



Validated access using separate domain user sessions on CLIENT01.



\## Simulated IAM Security Incident



\### Scenario



A Finance employee, Sarah Johnson, was mistakenly added to the IT security group `SG\_IT\_SUPPORT`.



This represented an inappropriate access assignment that violated least-privilege principles.



\### Investigation



1\. Verified Sarah initially lacked access to the IT share.

2\. Added Sarah to `SG\_IT\_SUPPORT` to simulate a misconfiguration.

3\. Refreshed her Windows logon session.

4\. Confirmed she could access the restricted IT folder.

5\. Reviewed the security group membership in Active Directory.



\### Root Cause



An inappropriate Active Directory security group assignment granted a Finance employee access to an IT-only resource.



\### Remediation



1\. Removed Sarah Johnson from `SG\_IT\_SUPPORT`.

2\. Refreshed the client logon session.

3\. Repeated the restricted-resource access test.

4\. Confirmed Windows denied Sarah access.

5\. Verified the group's final membership contained only Daniel Martinez.



\## Validation Results



| Test | Expected | Actual |

|---|---|---|

| Daniel accesses IT share | Allowed | Allowed |

| Sarah accesses IT share before misconfiguration | Denied | Denied |

| Sarah accesses share after unauthorized group assignment | Allowed | Allowed |

| Sarah accesses share after remediation | Denied | Denied |

| Final group membership review | Daniel only | Daniel only |



\## Skills Demonstrated



\- Active Directory Domain Services

\- Identity provisioning

\- Organizational unit administration

\- Security group management

\- Role-based access control

\- NTFS and SMB permissions

\- Least-privilege enforcement

\- Access testing

\- IAM incident investigation and remediation



\## Lessons Learned



Active Directory group membership directly affects authorization to resources protected by those groups.



An incorrect permission assignment can expose restricted resources to unauthorized identities.



Effective IAM administration requires not only granting approved access but also reviewing, revoking, and validating permissions.



\## Lab Disclaimer



This project was completed in an isolated personal homelab using fictional employee accounts. All incidents were simulated for educational purposes. No production systems were involved.





\---



\## Screenshot Evidence



The following screenshots document the Active Directory configuration,

access-control tests, simulated IAM incident, and remediation.



\### A1 — Active Directory Structure

!\[Active Directory structure](screenshots/01-ad-structure.png)



\### A2 — Security Group Configuration

!\[Active Directory group membership](screenshots/02-ad-group-membership.png)



\### A3 — NTFS Permissions

!\[NTFS permissions](screenshots/03-ntfs-permissions.png)



\### A4 — Access Configuration and Testing

!\[Share access test](screenshots/04-share-access-test.png)



\### A5 — IAM Access Evidence

!\[IAM access test](screenshots/05-iam-access-test.png)



\### A6 — Additional Evidence

!\[Lab evidence A6](screenshots/06-iam-evidence.png)



\### A7 — Additional Evidence

!\[Lab evidence A7](screenshots/07-iam-evidence.png)



\### A8 — Additional Evidence

!\[Lab evidence A8](screenshots/08-iam-evidence.png)



\### A9 — Additional Evidence

!\[Lab evidence A9](screenshots/09-iam-evidence.png)



\### A10 — Final Evidence

!\[Lab evidence A10](screenshots/10-iam-evidence.png)





