# Troubleshooting production instances

Here are some common issues that can occur in production, and how to solve them.

## General diagnostics

- How to browse the application logs:
    ```shell
    journalctl -xeu ds-web        # application server logs
    journalctl -xeu ds-sidekiq    # background jobs processor logs
    journalctl -xeu ds-weasyprint # weasyprint PDF converter logs
    ```
- How to see the background jobs queues status:

    As a super-admin, consult `https://<your-instance.org>/manager/sidekiq`.

## Common issues

### The website is unavailable (error 502)

- Inspect the status of the application web server (`systemctl status ds-web`)
- Restart the application web server (`systemctl restart ds-web`)
- Browse the application logs to look for an exception occurring during the application server startup (`journalctl -xeu ds-web`)

### The users need to be informed of an ongoing incident

You can display a message in a banner at the top of all pages of the application.

- Edit the `.env.production` file, and set the `BANNER_MESSAGE=""` variable to the message you want to display
- Then reload the settings by restarting the application server (`systemctl restart ds-web`)

### The home page redirects infinitely

Rails probably thinks the connection is made over HTTP, and redirects to the HTTPS version.

- Ensure that your reverse-proxy sends the proper headers to indicate the outgoing connection is secure (`HTTP_X_FORWARDED_PROTO`, `HTTPS` or `HTTP_X_FORWARDED_SSL`).

### The assets (CSS, JavaScript) are not loading

- Ensure the assets are compiled (`RAILS_ENV=production bin/rails assets:precompile`).
- Ensure your reverse-proxy serves the content of `/var/www/ds/public/` directly.

### No user receives any email

- Check your email settings and credentials in `.env.production`.
- Check whether your email provider has any outage going on.

### A user doesn't receive emails sent by the app (but other users do)

- Ask the user to check its Spam folder.
- Check your outgoing emails DMARK headers (e.g. using mail-tester.com).
- Check for typos in the user email address.
- Check on your email provider website that this email address hasn't been blocked.
- Check in the Manager that the user confirmed its email address ("email confirmed at"). Otherwise, click the "Unlock emails" button to confirm the email address manually.

### "Account will expire soon" emails are not sent, or some expiration tasks are not run

- Ensure that the recurring jobs are enqueued (`RAILS_ENV=production bin/rails jobs:schedule`).

### Uploading a file from the browser fails

- Ensure your Object Storage domain is allow-listed in the Content Security Policy (see `config/initializers/content_security_policy.rb`)
- Ensure your Object Storage is configured to allow CORS requests (see [Object Storage and Data Encryption](doc/object-storage-and-data-encryption.md))

### Sidekiq reports a lot of enqueued jobs

- Restart the ds-sidekiq service (`systemctl restart ds-sidekiq`).
- Purge the queue of pending-for-retry jobs that are never going to succeed anyway (in `Manager > Sidekiq`).

### Attachments are stuck in the "Pending antivirus analysis" state

- Check the Sidekiq queues (in `Manager > Sidekiq`), some of them may be clogged.
- Manually purge the queues, or restart the ds-sidekiq service (`systemctl restart ds-sidekiq`).

### Exports and archives are not generated

- Check the failed Sidekiq job that generates archives for an error message.
- Ensure the application system user has reading and writing rights to the directory specified by the `ARCHIVE_CREATION_DIR` env var.
- Ensure the `zip` command-line binary is available on the system.
- Watch for RAM usage for large exports.
