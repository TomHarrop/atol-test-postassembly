#!/usr/bin/env python3

from urllib.parse import urlparse


import requests
import os
from functools import cache

configfile: "config/config.yaml"


globals().update(config)


def get_storage_prefix(output_prefix):
    output_prefix_url = urlparse(output_prefix)
    netloc = output_prefix_url.netloc.lstrip("/")
    path = output_prefix_url.path.lstrip("/")
    return (output_prefix_url.scheme, Path(netloc, path).as_posix())


def to_storage(path_string, storage_prefix=None, registered_storage=storage.output):
    if storage_prefix is None:
        scheme, storage_prefix = get_storage_prefix(output_prefix)
    
    if isinstance(path_string, str):
        # this could mean it's a param that has been coerced to a string by
        # Snakemake
        path_string = path_string.split(f"{storage_prefix}/", 1)[1]
    
    if scheme == "s3":
        return  registered_storage(f"{scheme}://{storage_prefix}/{path_string}")
        # return registered_storage(f"{scheme}://{storage_prefix}/{path_string}")._flags["storage_object"].query
    elif scheme == "fs":
        return registered_storage(f"{storage_prefix}/{path_string}")
    else:
        raise NotImplementedError(f"Unknown storage scheme {scheme}")


def get_apikey():
    apikey = os.getenv("BPI_APIKEY")
    if not apikey:
        raise ValueError(
            "Set the BPI_APIKEY environment variable. "
            "This Snakefile uses a hack to pass the API key to `requests.get`. "
            "See  https://github.com/snakemake/snakemake-storage-plugin-http/issues/27."
        )
    return apikey


# @cache
def get_container(container_name):
    if container_name not in containers:
        raise ValueError(f"Container {container_name} not found in config.")
    my_container = containers[container_name]
    return (
        f"{my_container['prefix']}://"
        f"{my_container['url']}:"
        f"{my_container['tag']}"
    )


def get_url(wildcards):
    my_url = data_file_dict[wildcards.readfile]
    return storage.http(my_url)


# This is a hack. Redefine requests.get to include the Authorization header.
# snakemake_storage_plugin_http only supports predifined AuthBase classes, see
# https://github.com/snakemake/snakemake-storage-plugin-http/issues/27
requests_get = requests.get


def requests_get_with_auth_header(url, **kwargs):
    if "headers" not in kwargs:
        kwargs["headers"] = {}
    kwargs["headers"]["Authorization"] = get_apikey()
    return requests_get(url, **kwargs)


requests.get = requests_get_with_auth_header


# register storage for the workflow
try:
    storage output:
        provider = urlparse(output_prefix).scheme
except NameError as e:
    logger.error(
        """
Specify the output_prefix in config/config.yaml. Use snakemake prefixes, e.g.
s3://bucket.name/path for s3, or fs://path/to/directory for local folders. The
endpoint is currently configured in the profile.

For s3 configure the endpoint
and credentials via the profile or command line.
        """
    )
    raise e

rule download_from_bpa:
    input:
        get_url,
    output:
        temp(Path("resources", "reads", "{readfile}")),
    resources:
        runtime=lambda wildcards, attempt: int(30 * attempt),
    shell:
        "cp {input} {output}"
