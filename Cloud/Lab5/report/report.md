---
title: "Laboratory Work 05 — Azure Functions (FaaS)"
subtitle: "Integrated Services Networks and Cloud Technologies"
author: "Mark"
date: "2026-04-03"
---

# Objective

The objective of this laboratory work was to get familiar with **Function as a Service (FaaS)** using **Azure Functions**, including an **HTTP trigger** and a **Timer trigger**.

> **Note:** The original instructions describe creating resources in the Azure portal. For this work, the same result was implemented with **OpenTofu/Terraform** for infrastructure and **Azure CLI zip deployment** for the function code.

# 1. Infrastructure Deployment

The environment was provisioned in the `swedencentral` region under the resource group `FaaS_group`.

Created resources:

| Resource | Name | Region |
|---|---|---|
| Storage Account | `markfuncf872cd8f` | swedencentral |
| Service Plan | `mark-func-plan` | swedencentral |
| Application Insights | `mark-func-ai-f872cd8f` | swedencentral |
| Function App | `mark-func-f872cd8f` | swedencentral |

Key deployment settings:

- Plan: **Consumption** (`Y1`)
- Runtime: **Azure Functions v4**
- Language: **Python 3.11**
- Monitoring: **Application Insights enabled**

# 2. Work Progress

## 2.1 Function App Creation

Instead of creating the Function App manually in the portal, the following were provisioned automatically:

- Resource Group
- Storage Account
- Linux Consumption plan
- Function App
- Application Insights

The function source package was then deployed automatically with:

```bash
az functionapp deployment source config-zip
```

## 2.2 Implemented Functions

Two functions were deployed inside the Function App:

1. **HTTP trigger** at `/api/hello`
2. **Timer trigger** named `heartbeat`

The timer schedule was configured to run every minute:

```python
schedule="0 */1 * * * *"
```

## 2.3 HTTP Trigger Verification

Function URL:

```text
https://mark-func-f872cd8f.azurewebsites.net/api/hello
```

Invoked with query parameters:

```text
https://mark-func-f872cd8f.azurewebsites.net/api/hello?name=Mark&course=Cloud&extra=demo
```

Observed HTTP response:

```http
HTTP/1.1 200 OK
Content-Type: application/json
Server: Kestrel
```

Observed payload:

```json
{
  "message": "Hello, Mark! Your Azure Function is running.",
  "timestamp_utc": "2026-04-03T13:00:56.405672+00:00",
  "extra_params": {
    "extra": "demo",
    "course": "Cloud"
  }
}
```

This satisfies the lab requirement to pass `?name=<your name>` and also demonstrates an additional custom attribute through extra query parameters.

## 2.4 Timer Trigger Verification

The timer-triggered function was verified through Application Insights logs.

Observed trace entries:

```text
2026-04-03T13:00:00.0022594Z  Executing 'Functions.heartbeat' (Reason='Timer fired at 2026-04-03T13:00:00.0014100+00:00', ...)
2026-04-03T13:00:00.0158853Z  Timer trigger executed at 2026-04-03T13:00:00.010450+00:00
2026-04-03T13:00:00.0189327Z  Executed 'Functions.heartbeat' (Succeeded, ..., Duration=17ms)
```

This confirms that:

- the timer trigger was deployed correctly;
- the schedule was active;
- the function executed successfully at one-minute granularity.

## 2.5 Monitoring Observations

Immediately after app creation, Application Insights briefly showed startup messages indicating:

```text
0 functions found (Custom)
No functions were found...
```

This happened before the deployment package was fully applied. After zip deployment completed, the timer-trigger entries appeared successfully, confirming the application was functioning as intended.

## 2.6 Cleanup

After verification, the infrastructure was removed with:

```bash
terraform destroy -auto-approve
```

The Function App environment was cleaned up successfully.

# 3. Task Mapping to the Lab Sheet

## HTTP Function

The lab requested:

- create an HTTP-triggered function;
- set authorization level to anonymous;
- get the function URL;
- test it with `?name=<your name>`;
- tweak the code with an additional attribute.

All of these were completed:

- the HTTP endpoint was public and anonymous;
- the function URL was retrieved from Terraform outputs;
- the endpoint responded correctly to `?name=Mark`;
- extra query attributes such as `course` and `extra` were included in the JSON response.

## Time Function

The lab requested:

- create a timer-triggered function;
- change the schedule to run every minute;
- monitor logs to prove that it runs every minute.

All of these were completed:

- the timer trigger `heartbeat` was deployed;
- the schedule was changed to one minute;
- Application Insights logs showed a successful execution at `2026-04-03T13:00:00Z`.

# 4. Conclusion

The lab successfully demonstrated Azure Functions as a FaaS platform. A complete Function App environment was provisioned with Infrastructure as Code, and both required functions were deployed automatically. The HTTP trigger returned the expected JSON response with query parameters, while the timer trigger executed on schedule and recorded its activity in Application Insights. The environment was fully removed after verification.
