# Using SignPath with GitHub Actions

This project demonstrates signing artifacts using [SignPath](https://about.signpath.io) from GitHub Actions workflows.

Signing is invoked in the `sign` step of [.github/workflows/build-and-sign.yml](.github/workflows/build-and-sign.yml). 

See [github.com/SignPath/github-actions](https://github.com/SignPath/github-actions) for a full documentation of SignPath actions.

This project demonstrates the following attempts to violate SignPath policies and how they are averted on the control plane:

* This step selects the appropriate [signing policy] depending on the branch name. The actual branch must match the branch condition of the selected signing policy. The [`attempt-signing-release`] branch demonstrates how SignPath will detect incorrect attempts.
* The [`release/malicious-dll`] branch demonstrates how SignPath will detect content-level violations of the [artifact configuration].

[signing policy]: https://about.signpath.io/documentation/projects#signing-policies
[artifact configuration]: https://about.signpath.io/documentation/projects#artifact-configurations
[`attempt-signing-release`]: https://github.com/SignPath/github-actions-demo/blob/feature/attempt-signing-release/.github/workflows/build-and-sign.yml#L46
[`release/malicious-dll`]: https://github.com/SignPath/github-actions-demo/blob/release/malicious-dll/src/Build.ps1#L4
