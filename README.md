# SAML Reverse Proxy

Forked from: https://github.com/bsudy/saml-proxy

Apache HTTP server with this plugin: 
https://github.com/latchset/mod_auth_mellon

Docs:
https://jdennis.fedorapeople.org/doc/mellon-user-guide/mellon_user_guide.html

## Features

* SAML Single Sign On (Assertion using POST, PAOS, Artifact)
* SAML Single Sign Out (Frontend channel, SOAP)
* Forwarding of SAML Attributes as HTTP-Headers
* IDP Metadata fetched from remote URL during startup

## Environment variables

| Property   | Description  | Example  |
|----------|-------------|------|
| `BACKEND`| backend to proxy requests to, can be localhost when using as sidecar | `http://127.0.0.3000` (mandatory) |
| `PROXY_HOST`| host DNS record this proxy is available, without schema | `my-domain.com` (mandatory) |
| `PROXY_SCHEMA` | schema DNS on which proxy is available, however TLS termination is not handled, proxy does listen using http | `https` (default) |
| `LISTEN_PORT`| port to listen on, do not change if not in conflict | `3063` (default) |
| `IDP_METADATA`| A URL to the metadata from the IDP, downloaded when the container is started, can be internal k8s DNS | `https://<idp>/saml/descriptor` |
| `UNSECURED_URI` | location to be exposed as unsecured, usable for external healthchecks for example. | `/api/health` (optional)
| `REMOTE_USER_NAME_SAML_ATTRIBUTE`| the SAML attribute to be sent as `Remote-User-Email` HTTP header | `username` |
| `REMOTE_USER_EMAIL_SAML_ATTRIBUTE`| the SAML attribute to be sent as `Remote-User-Name` HTTP header | `EmailAddress` |
| `REMOTE_USER_PREFERRED_USERNAME_SAML_ATTRIBUTE`| the SAML attribute to be sent as `Remote-User-Preferred-Username` HTTP header | `PreferredUsername` |
| `SAML_MAP_<<sampl_field>>`| this will map the `saml_field` to a request header specified by the property | `SAML_MAP_EmailAddress=X-WEBAUTH-USER` will map `EmailAddress` SAML field to `X-WEBAUTH-USER` request header. |

## Volumes

| Path   | Description  | 
|----------|-------------|
| `/etc/httpd/conf.d/saml_idp.xml`| SAML IPD metadata (_mandatory_ unless using IDP_METADATA env) | 
| `/etc/httpd/conf.d/saml_sp.key`| SAML SP key (generated if not provided) | 
| `/etc/httpd/conf.d/saml_sp.cert`| SAML SP certificate (generated if not provided) | 
| `/etc/httpd/conf.d/saml_sp.xml`| SAML SP metadata (generated if not provided) | 


## SAML Descriptor example

```
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<EntityDescriptor
        entityID="<$PROXY_HOST>"
        xmlns="urn:oasis:names:tc:SAML:2.0:metadata">
    <SPSSODescriptor
            AuthnRequestsSigned="true"
            WantAssertionsSigned="true"
            protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
        <KeyDescriptor use="signing">
            <ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
                <ds:X509Data>
                    <ds:X509Certificate>MIICxDCCAawCCQ.....=</ds:X509Certificate>
                </ds:X509Data>
            </ds:KeyInfo>
        </KeyDescriptor>
        <KeyDescriptor use="encryption">
            <ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
                <ds:X509Data>
                    <ds:X509Certificate>MIICxDC.....=</ds:X509Certificate>
                </ds:X509Data>
            </ds:KeyInfo>
        </KeyDescriptor>
        <SingleLogoutService
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:SOAP"
                Location="<$PROXY_HOST>/mellon/logout" />
        <SingleLogoutService
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"
                Location="<$PROXY_HOST>/mellon/logout" />
        <NameIDFormat>urn:oasis:names:tc:SAML:2.0:nameid-format:transient</NameIDFormat>
        <AssertionConsumerService
                index="0"
                isDefault="true"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
                Location="<$PROXY_HOST>/mellon/postResponse" />
        <AssertionConsumerService
                index="1"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact"
                Location="<$PROXY_HOST>/mellon/artifactResponse" />
        <AssertionConsumerService
                index="2"
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:PAOS"
                Location="<$PROXY_HOST>/mellon/paosResponse" />
    </SPSSODescriptor>
</EntityDescriptor>

```

# Example use

For keycloak see info: https://www.keycloak.org/docs/latest/securing_apps/#_mod_auth_mellon

TBA