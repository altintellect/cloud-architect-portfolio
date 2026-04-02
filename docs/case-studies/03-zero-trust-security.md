# Case Study 03: Zero Trust Security Architecture

**Industry:** Healthcare  
**Timeline:** 10 months  
**Team Size:** 5 engineers  
**Cloud:** Azure (primary)

---

## Background

A regional healthcare provider with 8,000 employees and 42 clinics was operating
a traditional perimeter-based security model — once inside the network, users
and systems had broad access to sensitive patient data. A 2024 ransomware attack
on a peer organization processing similar data triggered an urgent board-level
mandate to modernize the security architecture.

The organization processed 2.4 million patient records and was subject to
HIPAA, PIPEDA, and provincial health data regulations. A data breach would
carry regulatory fines, reputational damage, and most critically, risk to
patient safety.

---

## Problem Statement

The existing security posture had critical gaps across every layer:

- Flat network — any compromised device could reach any system
- VPN-based remote access — full network access granted on connection
- Shared service accounts with passwords stored in spreadsheets
- No MFA enforced — single factor authentication on all systems
- Patient data accessible from any device on the corporate network
- No data loss prevention controls — USB drives freely used
- Security monitoring limited to firewall logs — no SIEM
- Patch compliance at 61% — 39% of systems running unpatched software

A penetration test conducted before the engagement found lateral movement
from a simulated compromised workstation to patient records in under 8 minutes.

---

## Solution Architecture

### Zero Trust Framework

Implemented Zero Trust across five pillars aligned to Microsoft's Zero Trust model:
