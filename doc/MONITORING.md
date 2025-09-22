# Monitoring

Here is some documentation about how to monitor the status of a running demarche-numerique instance.

## HTTP requests

Operators should monitor HTTP requests, especially the rate of 500 errors. A high rate of 500 errors probably indicates a production issue.

## Application logs

Application logs contain application warnings, exceptions and stacktraces. They will likely appear in two places:

- Web server (puma) logs: in `logs/production.txt` (or to `journalctl` if you configured the application to use systemd services).
- Asynchronous jobs logs: in `logs/sidekiq.txt` (or to `journalctl` if you configured sidekiq to use systemd services)

## Asynchronous jobs

The asynchronous jobs queues can be monitored by [super-admins](DEPLOYMENT.md), depending on the jobs backend used:

- `sidekiq`: https://ds42.adullact.org/manager/sidekiq
- `delayed_jobs`: https://ds42.adullact.org/manager/delayed_job

Slow queues may impact:
- The delivery of emails,
- The execution of export operations,
- The antivirus attachments analysis.

If you see too many "Waiting" jobs in some queues, you may want to restart the Sidekiq server, or drop the job(s) that are clogging the queues.

## Postgres

Use your standard system tools to monitor Postgres CPU and memory usage. You may walso want to monitor the queries response time, to know if some queries are slowing down the database, and why.

## Redis

Use your standard system tools to monitor Redis CPU and memory usage.

## Weasyprint

Use systemd to monitor the usage of the Weasyprint app server.

## Object Storage

You may want to monitor the Object Storage availability, to know if Object Storage requests are failing and why.

## Email delivery

Email providers tend to cause regular issues. They have two modes of failure:
- Global outage, no emails are sent. When this happens, a lot of features on demarche-numerique are not longer working correctly – starting with sign-in of Instructors (that requires an email confirmation). You may want to use the Manager to add an Announcement to users, stating that the email provided is down.
- Specific delivery issue with a single email. Emails can be blocked for a variety of reasons. Use the Manager to see the emails status for a specific user, or the dashboard of your email provider to see what is going on with a specific email address.

## Skylight

[Skylight](https://skylight.io) can be used to monitor the performances of requests to the app. Create an account and configure the relevant environment variables to use it.

## Sentry

[Sentry](https://sentry.io) can be configured to report frequently-ocurring exceptions. Both the SaaS and self-hosted version of Sentry are supported. Create an account and configure the relevant environment variables to use it.
