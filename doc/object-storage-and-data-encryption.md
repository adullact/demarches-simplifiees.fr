# Object Storage And Data Encryption

## Object Storage configuration

By default, demarche-numerique uses an S3-compatible Object Storage (this can be genuine Amazon Web Services S3 service, or any compatible object storage, hosted by OVH, Scaleway, or other).

demarche-numerique allows users to directly upload files to the Object Storage, without going through the application stack (this is often called "Direct Upload"). For this to work, the Object Storage needs to **allow CORS requests from the application domain**.

For this, you may want to configure your Object Storage using the `aws` command-line tool:

```shell
export CORS='{"CORSRules":[{"AllowedHeaders":["*"],"AllowedMethods":["*"],"AllowedOrigins":["https://ds.example.org"]}]}'
aws --endpoint https://object-storage.example.org s3api put-bucket-cors --bucket ds-bucket --cors-configuration $CORS
```

## Object Storage and encryption

The Object Storage hard-drives are usually encrypted at rest. To protect user files even better, demarche-numerique can also use an external encryption proxy, that will encrypt and decrypt files on the fly:

* Encryption is done via our [proxy](https://github.com/betagouv/ds_proxy) when the file is uploaded by a client.
* Decryption is done via the same proxy when the file is downloaded to a client

### Object Storage limitation

As an s3 compatible object storage backend, OVH Object Storage suffers the same limitations.

One of them being that when you upload a file bigger than 5Go, it must be chunked into segments (see the [documentation](https://docs.ovh.com/fr/storage/pcs/capabilities-and-limitations/#max_file_size-5368709122-5gb)).

This process to chunks the file in segment, then re-arrange it via a manifest. Unfortunately encryption can't work with this usecase.

So we are using a custom script that wraps two call to our proxy in order to buffer all the chunks, encrypt/decrypt the whole. Here is an example

```
#!/usr/bin/env bash
# wrapper script to encrypt and upload file received from archive

set -o errexit
set -o pipefail
set -o nounset

# params
# 1: filename
# 2: key
if ! [ "$#" -eq 2 ]; then
    echo "usage: $0 <filename> <key>"
    exit 1
fi
local_file_path=$1
remote_basename=$(basename $local_file_path)
key=$2

# encrypt
curl -s -XPUT http://ds_proxy_host:ds_proxy_port/local/encrypt/${remote_basename} --data-binary @${local_file_path}

# get back encrypted file
encrypted_filename="${local_file_path}.enc"
curl -s http://ds_proxy_host:ds_proxy_port/local/encrypt/${remote_basename} -o ${encrypted_filename}

# OVH openstack params
os_tenant_name=os_tenant_name
os_username=os_username
os_password=os_password
os_region_name=GRA

# auth = https://auth.cloud.ovh.net/v3/
# use haproxy proxy and not direct internet URL
os_auth_url="os_auth_url"
os_storage_url="os_storage_url" \
container_name=container_name

expiring_delay="$((60 * 60 * 24 * 4))" # 4 days

# upload
/usr/local/bin/swift \
  --auth-version 3 \
  --os-auth-url "$os_auth_url" \
  --os-storage-url "$os_storage_url" \
  --os-region-name "$os_region_name" \
  --os-tenant-name "$os_tenant_name" \
  --os-username "$os_username" \
  --os-password "$os_password" \
  upload \
  --header "X-Delete-After: ${expiring_delay}" \
  --segment-size "$((3 * 1024 * 1024 * 1024))" \
  --header "Content-Disposition: filename=${remote_basename}" \
  --object-name "${key}" \
  "${container_name}" "${encrypted_filename}"

swift_exit_code=$?

# cleanup
rm ${encrypted_filename}

# return swift return code
exit ${swift_exit_code}
```


