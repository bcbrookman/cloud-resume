"""Pulumi code to deploy edge infra on Cloudflare"""

import json
import pulumi
import pulumi_cloudflare as cloudflare


config = pulumi.Config()
zone_id = config.require_secret("zoneId")
bicep_file = f"../bicep-output.{config.require('environment')}.json"

with open(bicep_file, "r") as f:
    bicep_output = json.load(f)
    frontend_edge_fqdn = bicep_output['properties']['outputs']['frontendEdgeFqdn']['value']
    frontend_edge_verify_fqdn = bicep_output['properties']['outputs']['frontendEdgeVerifyFqdn']['value']
    frontend_origin_fqdn = bicep_output['properties']['outputs']['frontendOriginFqdn']['value']
    api_edge_fqdn = bicep_output['properties']['outputs']['apiEdgeFqdn']['value']
    api_edge_fqdn_verify_txt = bicep_output['properties']['outputs']['apiEdgeFqdnVerifyTxt']['value']
    api_origin_fqdn = bicep_output['properties']['outputs']['apiOriginFqdn']['value']

frontend_edge_dns_record = cloudflare.DnsRecord(
    "frontendEdgeDnsRecord",
    zone_id=zone_id,
    name=frontend_edge_fqdn,
    type="CNAME",
    content=frontend_origin_fqdn,
    proxied=True,
    ttl=1,  # automatic
)

frontend_verify_dns_record = cloudflare.DnsRecord(
    "frontendVerifyDnsRecord",
    zone_id=zone_id,
    name="asverify." + frontend_edge_fqdn,
    type="CNAME",
    content=frontend_edge_verify_fqdn,
    proxied=False,
    ttl=1,  # automatic
)

api_edge_dns_record = cloudflare.DnsRecord(
    "apiEdgeDnsRecord",
    zone_id=zone_id,
    name=api_edge_fqdn,
    type="CNAME",
    content=api_origin_fqdn,
    proxied=False,
    ttl=1,  # automatic
)

api_verify_dns_record = cloudflare.DnsRecord(
    "apiVerifyDnsRecord",
    zone_id=zone_id,
    name='asuid.' + api_edge_fqdn,
    type="TXT",
    content=api_edge_fqdn_verify_txt,
    proxied=False,
    ttl=1,  # automatic
)
