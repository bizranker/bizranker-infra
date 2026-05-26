# BizRanker UI Known Bugs

## Surface button does not return to top from Market Intelligence

Status: Open

Host:
- bizranker-web-01

App:
- bizranker-ui
- ui.usreliance.com

Symptom:
- When user navigates to Market Intelligence, the floating “Surface ↑” button does not return the user to the top.
- Closing the hamburger/menu does not resolve it.

Likely cause:
- Surface button currently scrolls to an element or state that may not exist / may not be rendered when `activeView` is not `command`.
- Needs to either:
  1. set `activeView` back to `command`, then scroll to `dashboard-top`, or
  2. always scroll the main page/container to top regardless of active route/view.

Priority:
- Medium-high UX polish issue.
- Fix before calling v1.0 UI foundation fully polished.

Notes:
- Ansible control center validated from WSL.
- All four realm hosts currently respond to Ansible ping.
