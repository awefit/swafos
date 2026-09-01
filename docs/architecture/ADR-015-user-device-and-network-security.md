# ADR-015 — User Device & Network Security Policy

- Status: Proposed
- Date: 2026-09-01
- Depends on: ADR-014

## Decision

SWAFOS will support registered-device and network-aware security as configurable security controls, but it will not treat a fixed IP address as a universal identity proof.

The primary identity remains the authenticated user plus strong authentication. Device and network signals provide additional risk controls.

## Registered Device

A user may register one or more trusted devices. A device record should support:

- device identifier / cryptographic key reference;
- platform and app metadata;
- registration timestamp;
- last-seen timestamp;
- status (pending, active, revoked, expired);
- organization/user scope;
- security events associated with the device.

Sensitive operations may require a trusted active device.

## IP / Network Policy

Tenants may define network policies as part of their SOP, including:

- allowed IP addresses or CIDR ranges;
- trusted networks;
- optional VPN/private-network requirements;
- behavior when an IP changes;
- whether a network restriction applies to all access or only sensitive actions.

However, IP is treated as a network signal, not a permanent identity. Mobile networks, carrier NAT, IPv6 privacy addressing, proxies, VPNs, and changing ISP addresses can make strict IP pinning operationally fragile.

## Security Levels

SWAFOS should support configurable policies such as:

### Standard

Authenticated user + normal device checks.

### Elevated

Authenticated user + registered device + additional authentication when risk is elevated.

### Restricted

Registered device and approved network required for sensitive actions.

### Break-glass

Exceptional platform operations with strong authentication, explicit reason/reference, time-bound privilege, and audit.

These levels are policy primitives; tenants can configure their SOP within platform safety limits.

## Risk-Based Enforcement

A change in IP, device, location, or session characteristics should not automatically lock a legitimate user solely because the signal changed. SWAFOS should support risk scoring and step-up authentication where practical.

Examples of higher-risk signals:

- new/unregistered device;
- impossible or highly unusual session transition;
- suspicious IP/network reputation;
- sudden change in access pattern;
- repeated authentication failures;
- sensitive operation from an untrusted context.

## Tenant vs Platform Controls

Tenant SOP controls may tighten access requirements for their organization, but may not disable mandatory platform security controls.

Platform-level controls may require stronger authentication or block access when a severe security condition is detected.

## Privacy

Device and network metadata should be collected only to the extent necessary for security, retained according to a documented retention policy, and protected as security-sensitive data.

## Consequences

### Positive

- Stronger protection against credential theft.
- Tenant-configurable security SOP.
- Better resilience than relying exclusively on IP pinning.
- Clear step-up path for sensitive business actions.

### Trade-off

Device registration, recovery, lost-device handling, and IP/network changes require explicit operational UX and support procedures.
