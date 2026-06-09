## Description: <br>
Claude Code Integration provides OpenClaw users with local Claude Code documentation lookups, workflow guidance, troubleshooting help, and task handoff prompts for AI-assisted development. <br>

This skill is ready for commercial/non-commercial use. <br>

## Publisher: <br>
[hw10181913](https://clawhub.ai/user/hw10181913) <br>

### License/Terms of Use: <br>


## Use Case: <br>
Developers and engineers use this skill inside OpenClaw to query bundled Claude Code guidance, review workflow recommendations, and prepare coding task descriptions for OpenClaw-native execution. <br>

### Deployment Geography for Use: <br>
Global <br>

## Known Risks and Mitigations: <br>
Risk: Bundled Claude Code documentation and workflow guidance may become stale. <br>
Mitigation: Compare important guidance against the current Claude Code documentation before relying on it for setup, security, or production workflow decisions. <br>
Risk: The task command describes an OpenClaw handoff but does not itself execute the requested development work. <br>
Mitigation: Use OpenClaw's native execution or subagent tools for actual work, and review the generated task description before execution. <br>
Risk: Remote installer snippets or separate OpenClaw exec/read-write actions can change local files or execute external code. <br>
Mitigation: Review installer commands and any OpenClaw execution plan before running them in a trusted workspace. <br>


## Reference(s): <br>
- [Claude Code Documentation](https://code.claude.com/docs) <br>
- [Claude Code Quickstart](https://code.claude.com/docs/en/quickstart) <br>
- [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices) <br>
- [Claude Code Common Workflows](https://code.claude.com/docs/en/common-workflows) <br>
- [Claude Code Troubleshooting](https://code.claude.com/docs/en/troubleshooting) <br>
- [ClawHub Skill Page](https://clawhub.ai/hw10181913/claude-code) <br>


## Skill Output: <br>
**Output Type(s):** [text, markdown, shell commands, configuration, guidance] <br>
**Output Format:** [Markdown and plain text with inline shell command examples] <br>
**Output Parameters:** [1D] <br>
**Other Properties Related to Output:** [Task output is a handoff description for OpenClaw-native execution rather than direct code execution.] <br>

## Skill Version(s): <br>
1.0.0 (source: server release evidence and README version) <br>

## Ethical Considerations: <br>
Users should evaluate whether this skill is appropriate for their environment, review any generated or modified files before relying on them, and apply their organization's safety, security, and compliance requirements before deployment. <br>
