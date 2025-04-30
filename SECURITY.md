# Security Policy

## Supported Versions

Until we have the version 1.0 we support only the last two minor versions with
security updates.

Exceptionally, we are also extending support for v0.27 until October 2025, as it
is the last version with the old design. This marks 18 months since the release
of v0.28, giving ample time for organizations to upgrade to newer versions that
include the latest design and features.


| Version  | Supported          |
| -------- | ------------------ |
| 0.30.x   | :white_check_mark: |
| 0.29.x   | :white_check_mark: |
| 0.28.x   | :x: |
| 0.27.x   | :white_check_mark: |
| \<= 0.26 | :x:                |

## Reporting a Vulnerability

Security is very important to us.

If you have any issue regarding security, please disclose the information
responsibly by sending an email to security [at] decidim [dot] org and not by
creating a github/metadecidim issue.

We appreciate your effort to make Decidim more secure.

We recommend to use GPG for these kind of communications, the fingerprint is
`C1BD 8981 D83C 23F9 D419 FE42 149A D0F9 84B9 35C4`.

To download our key:

```bash
gpg --keyserver pgp.mit.edu --recv 84B935C4
```

## Vulnerability disclosure policy

Working with security issues in an open source project can be challenging, as
we are required to disclose potential problems that could be exploited by
attackers. With this in mind, our security fix policy is as follows:

1. The Maintainers team will handle the fix as usual (Pull Request, backport,
release).
1. In the release notes, we will include the identification numbers from the
GitHub Advisory Database (GHSA) and, if applicable, the Common Vulnerabilities
and Exposures (CVE) identifier for the vulnerability.
1. We will provide a grace period of 2 months for implementers to update to a
patched version. In the case of critical security issues, the grace period will
be extended to 4 months.
1. Once this grace period has passed, we will publish the vulnerability.

By adhering to this security policy, we aim to address security concerns
effectively and responsibly in our open source software project.
