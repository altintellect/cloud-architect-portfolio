# Case Study 03: Zero Trust Security Architecture

**Industry:** Healthcare
**Timeline:** 10 months
**Team Size:** 5 engineers
**Cloud:** Azure (primary)

---

## Background

A regional healthcare provider with 8,000 employees and 42 clinics was operating
a traditional perimeter-based security model. A 2024 ransomware attack on a peer
organization triggered an urgent board-level mandate to modernize the security
architecture. The organization processed 2.4 million patient records and was
subject to HIPAA, PIPEDA, and provincial health data regulations.

---

## Problem Statement

- Flat network - any compromised device could reach any system
- VPN-based remote access - full network access granted on connection
- Shared service accounts with passwords stored in spreadsheets
- No MFA enforced - single factor authentication on all systems
- Patient data accessible from any device on the corporate network
- No data loss prevention controls - USB drives freely used
- Security monitoring limited to firewall logs - no SIEM
- Patch compliance at 61% - 39% of systems running unpatched software
- Penetration test found lateral movement to patient records in under 8 minutes

---

## Solution Architecture

### Zero Trust Framework - Five Pillars

### Pillar 1 - Identity

- Migrated all 8,000 users to Azure AD with Hybrid Identity (AD Connect)
- Enforced MFA for all users - no exceptions
- Conditional Access policies requiring compliant device and MFA for all apps
- Privileged Identity Management for all administrative roles
- Just-in-time access replacing standing privileged accounts
- Password protection blocking 500+ known weak passwords
- Eliminated all shared service accounts - replaced with Managed Identities
- All remaining service accounts stored in Azure Key Vault

### Pillar 2 - Devices

- All 6,200 endpoints enrolled in Microsoft Intune within 60 days
- Compliance policies requiring encryption, patch level, AV status
- Non-compliant devices blocked from accessing patient data via Conditional Access
- Mobile Device Management for 1,800 clinical tablets
- Microsoft Defender for Endpoint deployed to all endpoints for EDR capability
- Attack surface reduction rules enabled
- Automated investigation and remediation enabled

### Pillar 3 - Network

- Replaced VPN with Azure AD Application Proxy and Private Access
- Users access only specific applications, not the entire network
- All remote access sessions logged and monitored
- Redesigned flat network into segmented zones
- Azure Firewall Premium as central inspection point
- NSGs with deny-all defaults on all subnets
- Patient data systems isolated in dedicated VLAN with strict ACLs
- TLS 1.3 enforced for all application traffic
- mTLS between all internal microservices

### Pillar 4 - Data

| Classification | Examples | Controls |
|---|---|---|
| Public | Website content | Standard |
| Internal | Staff communications | Encryption + RBAC |
| Confidential | Administrative records | MIP labels + DLP |
| Restricted | Patient health records | MIP labels + DLP + audit |

- Microsoft Information Protection labels applied to all patient data
- Data Loss Prevention policies blocking USB transfer of patient records
- Azure Purview for data discovery and classification
- Customer Managed Keys for all patient data at rest
- Private Endpoints for all storage and database services

### Pillar 5 - Applications

- All 47 clinical applications integrated with Azure AD SSO
- Legacy applications wrapped with Azure AD Application Proxy
- Session risk evaluated continuously - high risk triggers step-up MFA
- Application-level audit logging for all patient data access
- Microsoft Sentinel SIEM with 90-day log retention
- Custom detection rules for healthcare-specific threats
- Automated playbooks for common incident types

---

## Challenges and Solutions

### Challenge 1 - Clinical Workflow Disruption

Clinicians resisted MFA citing patient safety concerns.

Solution: Implemented Windows Hello for Business on clinical workstations.
Biometric authentication is faster than password entry. Break-glass accounts
created for genuine emergencies with full audit trail. Ran 60-day pilot with
200 clinical staff before full rollout. Clinician satisfaction with
authentication actually improved due to SSO eliminating 12 separate logins.

### Challenge 2 - Legacy Medical Devices

142 medical devices ran Windows XP/7 and could not be patched or enrolled in Intune.

Solution: Isolated all legacy medical devices in dedicated network segment
with no internet access and strict firewall rules. Compensating controls
documented for compliance. Device replacement roadmap created with clinical
operations team.

### Challenge 3 - HIPAA Compliance Validation

Legal team required documented evidence that Zero Trust controls satisfied HIPAA.

Solution: Created a HIPAA control mapping document linking every HIPAA
technical safeguard to specific Azure service configurations. Engaged
Microsoft Healthcare compliance team for validation. Achieved HIPAA
compliance attestation within 8 months.

---

## Results

| Metric | Before | After | Improvement |
|---|---|---|---|
| MFA coverage | 0% | 100% | Full coverage |
| Patch compliance | 61% | 96% | 57% improvement |
| Lateral movement time (pen test) | 8 minutes | Not achieved | Attack path eliminated |
| Privileged standing accounts | 847 | 0 | 100% eliminated |
| Mean time to detect threat | Unknown | 4 minutes | Measurable for first time |
| Shared service accounts | 203 | 0 | 100% eliminated |
| USB data exfiltration incidents | 14/year | 0 | 100% reduction |
| Security audit findings | 47 critical | 3 low | 94% reduction |

---

## Key Lessons Learned

Identity is the new perimeter. Every security improvement flowed from
getting identity right first. Strong Azure AD foundation with Conditional
Access made every other pillar more effective.

Involve clinicians in security design. Security controls that disrupt
clinical workflow create workarounds that are less secure than the original
problem. Clinical champions embedded in the project team prevented 6
potential workflow blockers before they became issues.

Compensating controls are valid architecture. Legacy medical devices
that cannot be patched are a reality in healthcare. Documented compensating
controls with network isolation is a legitimate and auditable security posture.

---

## Technologies Used

- Azure Active Directory, Conditional Access, PIM
- Microsoft Intune, Autopilot, Windows Hello for Business
- Microsoft Defender for Endpoint, Defender for Cloud
- Azure Firewall Premium, Network Security Groups
- Azure AD Application Proxy, Global Secure Access
- Microsoft Information Protection, Azure Purview
- Microsoft Sentinel, Logic Apps (SOAR playbooks)
- Azure Key Vault, Customer Managed Keys
- Private Endpoints for all PaaS services
- Terraform for all infrastructure provisioning
