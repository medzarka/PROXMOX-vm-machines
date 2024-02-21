import routeros_api

# based on steps from https://docs.sim-cloud.net/en/solutions-virtual-router/mikrotik/basic-setting.html


### Config
DEVICE_NAME = 'pve01_router'
DEVICE_IP = '192.168.20.202'
ADMIN_USER_NAME = 'admin'
ADMIN_USER_PASSWORD = 'ZWdl@LZ5id#V3uLO2duE@f4#AVyl2@KEo#0fq#Lwo#3T@6W#yA1r#MSsb#Wij@Ikp#APhc7#euZS3ul@8nbLG#9rw#'
FULL_USER_NAME = 'mzarka'
FULL_USER_PASSWORD = '#XTra8#M3#Dg@A9mPO1dm@RZex#6Fy#9xFV8lJ#w3#VPmu#FZo@7Jy#Cjk@RR3o#X2iiC#iB#0sG3tS2#usWX6jnI0'
READ_USER_NAME = 'reader'
READ_USER_PASSWORD = 'a#Zdq@9v@R2cfVG3#DUl6JZ@qE#4Lo1V#b2@Ib#Kkl2Ui#Qa#YUv#Ekg9P#6kh#3Mb@AYrq#Fzs3Ruv9#KEdn@5m@T'

### Methods

def change_user_password(_api, _username, _new_password):
    try:
        # Fetch the user list
        users = _api.get_resource('/user')

        # Find the user to modify
        user_to_modify = None
        for user in users:
            if user.get('name') == _username: 
                user_to_modify = user
                break

        if user_to_modify:
            user_to_modify.set('password', _new_password)  # Change password
            #user_to_modify.set('group', 'read')  # Change group (optional)
            print("User data modified successfully!")
        else:
            print("User not found.")
    except routeros_api.RouterOsApiConnectionError as _e:
        print("Connection error:", _e)
    except routeros_api.RouterOsApiCommandError as _e:
        print("Command error:", _e)
    except routeros_api.exceptions.TrapError as _e:
        print("Error adding user:", _e)

def add_user(_api, _username, _password, _group):
    try:
        _api.add_user(
            name=_username,
            password=_password,
            group=_group,  # Optional: Specify the user group (e.g., 'read', 'write', 'full')
        )
        print("User added successfully!")
    except routeros_api.RouterOsApiConnectionError as _e:
        print("Connection error:", _e)
    except routeros_api.RouterOsApiCommandError as _e:
        print("Command error:", _e)
    except routeros_api.exceptions.TrapError as _e:
        print("Error adding user:", _e)

def disable_user(_api, _username):
    try:
        _api.talk(["/user/disable", f"=name={_username}"])
        print("Admin user disabled successfully.")
    except routeros_api.RouterOsApiConnectionError as _e:
        print("Connection error:", _e)
    except routeros_api.RouterOsApiCommandError as _e:
        print("Command error:", _e)
    except routeros_api.exceptions.TrapError as _e:
        print("Error adding user:", _e)

def update_system_name(_api, _new_name):
    try:
        _api.get_binary_resource("/system/identity/set", {"name": _new_name})
        print(f"System name changed to: {DEVICE_NAME}")
    except routeros_api.RouterOsApiConnectionError as _e:
        print("Connection error:", _e)
    except routeros_api.RouterOsApiCommandError as _e:
        print("Command error:", _e)
    except routeros_api.exceptions.TrapError as _e:
        print("Error adding user:", _e)

def disable_system_service(_api, _service_name):
    try:
        _api.command("/ip/service/set", {"name": _service_name, "disabled": "yes"})
        print("FTP service disabled successfully.")
    except routeros_api.RouterOsApiConnectionError as _e:
        print("Connection error:", _e)
    except routeros_api.RouterOsApiCommandError as _e:
        print("Command error:", _e)
    except routeros_api.exceptions.TrapError as _e:
        print("Error adding user:", _e)

def network_create_firewall_zone(_api, _firewall_zone, _firewall_zone_description='', masquerade=False):
    try:
        api.add_zone(name=_firewall_zone, comment=_firewall_zone_description)
        print(f"Firewall zone {_firewall_zone} created successfully.")

        if masquerade is True:
            nat_rule = {
                "action": "masquerade",
                "out-interface": _firewall_zone,  # Replace with your outgoing interface name
            }
            api.add("/ip/firewall/nat", nat_rule)
            print("Masquerade NAT rule added successfully!")

    except routeros_api.RouterOsApiConnectionError as _e:
        print("Connection error:", _e)
    except routeros_api.RouterOsApiCommandError as _e:
        print("Command error:", _e)
    except routeros_api.exceptions.TrapError as _e:
        print("Error adding user:", _e)

def network_create_firewall_rule(_api, _chain, _action, _src_address, _dst_address, _protocol='any', _src_port='any', _dst_port='any'):
    try:

        api.get_binary_resource = True  # Required for firewall API calls

        if _chain == 'forward':
            _api.get_binary("/ip/firewall/filter/print")  # Check if rule already exists
            _api.add_firewall_rule(chain=_chain, action=_action, protocol=_protocol,
                                src_address=_src_address, src_port=_src_port,
                                dst_address=_dst_address, dst_port=_dst_port)
            print(f"Firewall forward rule created successfully. ({_src_address} --> {_dst_address} : {_action})")

        if _chain == 'dstnat':
            _api.get_binary("/ip/firewall/filter/print")  # Check if rule already exists
            api.add_nat_rule(chain=_chain, action=_action, protocol=_protocol, # chain=dstnat, and action='dst-nat'
                        src_address=_src_address, dst_port=_src_port,
                        to_addresses=_dst_address, to_ports=_dst_port)
            print(f"Firewall nate rule created successfully. ({_src_address}:{_dst_port} --> {_dst_address}:{_dst_port}/{_protocol})")

        if _chain == 'input':
            _api.get_binary("/ip/firewall/filter/print")  # Check if rule already exists
            _api.add_firewall_rule(chain=_chain, action=_action, protocol=_protocol,
                        src_address=_src_address, src_port=_src_port,
                        dst_address=_dst_address, dst_port=_dst_port)
            print(f"Firewall nate rule created successfully. ({_src_address}:{_src_port} --> {_dst_address}:{_dst_port}/{_protocol})")

    except routeros_api.RouterOsApiConnectionError as _e:
        print("Connection error:", _e)
    except routeros_api.RouterOsApiCommandError as _e:
        print("Command error:", _e)
    except routeros_api.exceptions.TrapError as _e:
        print("Error adding user:", _e)

def network_config_network_interface(_api, _interface, _address, _firewall_zone, _vlan_id=None, _gateway=None, _dns=None):
    try:
        if _vlan_id is not None:
            # add Vlan id
            api.add_vlan(vlan_id=_vlan_id)
            print(f'VLAN {_vlan_id} created successfully.')

            # Add interface to the VLAN
            api.add_vlan_interface(interface=_interface, vlan_id=_vlan_id)
            print(f'Interface {_interface} added to VLAN {_vlan_id}.')

            _interface = f'vlan{_vlan_id}'
            print(f'Vlan Interface updated to {_interface}')

        # Set VLAN interface IP address
        api.set_ip_address(interface=_interface, address=_address)
        print(f'Interface {_interface} added address {_address} successfully.')

        # add the vlan interface to the zone
        api.execute('/interface/ethernet/set', **{'name': _interface, 'zone': _firewall_zone})
        print(f'Interface {_interface} added to firewall zone {_firewall_zone} successfully.')

        if _gateway is not None:
            api.get_binary_resource('/ip/route/print').add('0.0.0.0/0', gateway=_gateway)
            print("Gateway configured successfully")

        if _dns is not None:
            api.get_binary_resource('/ip/dns/set').call({'servers': _dns})
            print("DNS configured successfully")

    except routeros_api.RouterOsApiConnectionError as _e:
        print("Connection error:", _e)
    except routeros_api.RouterOsApiCommandError as _e:
        print("Command error:", _e)
    except routeros_api.exceptions.TrapError as _e:
        print("Error adding user:", _e)

def system_config_timezone(_api, _timezone):
    try:
        api.get_binary_resource("/system/clock")  # Ensure initial connection
        api.set_resource("/system/clock", {"time-zone-name": _timezone})
        print(f'Time zone configured successfully to {_timezone}.')
    except routeros_api.RouterOsApiConnectionError as _e:
        print("Connection error:", _e)
    except routeros_api.RouterOsApiCommandError as _e:
        print("Command error:", _e)
    except routeros_api.exceptions.TrapError as _e:
        print("Error adding user:", _e)

def system_enable_ntp(_api):
    try:
        # Enable NTP client
        api.get_binary_resource('/system/ntp/client').call('set', enabled='yes')
        api.get_resource('/system/ntp/servers').call('set', servers=[
            '0.pool.ntp.org',
            '1.pool.ntp.org',
            '2.pool.ntp.org'
        ])
        print("NTP client enabled successfully.")

        # Enable NTP Server
        api.talk('/system/ntp/set enabled=yes')
        api.talk('/system/ntp/set primary-ntp=0.pool.ntp.org')
        api.talk('/system/ntp/set secondary-ntp=1.pool.ntp.org')
        print("NTP server enabled successfully.")
    except routeros_api.RouterOsApiConnectionError as _e:
        print("Connection error:", _e)
    except routeros_api.RouterOsApiCommandError as _e:
        print("Command error:", _e)
    except routeros_api.exceptions.TrapError as _e:
        print("Error adding user:", _e)

# ---------------------------------------------------------------------------------------
### Steps
# ---------------------------------------------------------------------------------------

# Connect to the RouterOS device
connection = routeros_api.RouterOsApiPool(DEVICE_IP, username=ADMIN_USER_NAME, password='123')
api = connection.get_api()

# Users
add_user(api, FULL_USER_NAME, FULL_USER_PASSWORD, "full")  # Add the new full permissions user
add_user(api, READ_USER_NAME, READ_USER_PASSWORD, "read")  # Add the new read only permissions user

# System name
update_system_name(api, DEVICE_NAME) # update system name

# System services (ip service print --> telnet (23), ftp (21), www (80), ssh (22), www-ssl (443), api (8728), winbox (8291))
disable_system_service(api, 'telnet') # disable telnet service
disable_system_service(api, 'ftp') # disable ftp service
disable_system_service(api, 'winbox') # disable winbox service
disable_system_service(api, 'ssh') # disable ssh service

# Network (WAN and LAN)
network_create_firewall_zone(api, 'WAN', 'External Zone', masquerade=True)
network_create_firewall_zone(api, 'DMZ', 'Demilitarized Zone')
network_create_firewall_zone(api, 'LAN', 'Local Network Zone')

network_config_network_interface(api, 'ether1', '10.10.0.1/24', 'WAN', None) # HOST
network_config_network_interface(api, 'ether2', '10.10.10.1/24', 'LAN', 10) # HOST
network_config_network_interface(api, 'ether2', '10.10.20.1/24', 'DMZ', 20) # DMZ
network_config_network_interface(api, 'ether2', '10.10.30.1/24', 'LAN', 30) # VMs
network_config_network_interface(api, 'ether2', '10.10.40.1/24', 'LAN', 40) # LXCs
network_config_network_interface(api, 'ether2', '10.10.50.1/24', 'LAN', 50) # TEMPLATES




#########   Firewall forward, input, nat)

network_create_firewall_rule(_api=api, _chain="forward", _action="accept", _src_address="LAN", _dst_address="WAN")  # Allow traffic from LAN to WAN
network_create_firewall_rule(_api=api, _chain="forward", _action="accept", _src_address="DMZ", _dst_address="WAN")  # Allow traffic from DMZ to WAN
network_create_firewall_rule(_api=api, _chain="forward", _action="accept", _src_address="LAN", _dst_address="DMZ")  # Allow traffic from LAN to DMZ
network_create_firewall_rule(_api=api, _chain="forward", _action="drop", _src_address="DMZ", _dst_address="LAN")  # Drop traffic from DMZ to LAN
network_create_firewall_rule(_api=api, _chain="forward", _action="drop", _src_address="WAN", _dst_address="LAN")  # Drop traffic from WAN to LAN

# Firewall port farwarding  (chain=dstnat, and action='dst-nat')
network_create_firewall_rule(_api=api, _chain="dstnat", _action='dst-nat', _src_address='0.0.0.0/0', _dst_address='192.168.88.254', _protocol='tcp', _src_port=2222, _dst_port=22)

# Firewall input filtering
network_create_firewall_rule(_api=api, _chain="input", _action="accept", _src_address="0.0.0.0/0", _dst_address='192.168.88.10', _protocol='tcp', _src_port='any', _dst_port='80')






# Configure time zone (system clock print)
system_config_timezone(api, 'Asia/Riyadh')
# Configure NTP Server/Client
system_enable_ntp(api)



api.logout() # disconnect
