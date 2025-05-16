param location string
param nsgName string
param uaidName string

module userAssignedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.0' = {
  name: 'userAssignedIdentityDeployment'
  params: {
    // Required parameters
    name: uaidName
    // Non-required parameters
    location: location
  }
}

//create network security group
module networkSecurityGroup 'br/public:avm/res/network/network-security-group:0.5.0' = {
  name: 'networkSecurityGroupDeployment'
  params: {
    // Required parameters
    name: nsgName
    // Non-required parameters
    location: location
    securityRules: [
      {
        name: 'allow-inbound-http'
        properties: {
            access: 'Allow'
            destinationAddressPrefix: '*'
            destinationPortRanges: [
            '80'
            '443'
            ]
            direction: 'Inbound'
            priority: 200
            protocol: 'Tcp'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
        }
      }
      {
        name: 'AllowKubelet'
        properties: {
          priority: 1000
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '10250'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowDNS'
        properties: {
          priority: 1010
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Udp'
          sourcePortRange: '*'
          destinationPortRange: '53'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowInternetOutbound'
        properties: {
          priority: 1100
          direction: 'Outbound'
          access: 'Allow'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
        }
      }
    ]
  }
}

param vnetName string
param addressSpace string
param systemPoolSubnetName string
param userPool1SubnetName string
param userPool2SubnetName string

//create virtual network
module virtualNetwork 'br/public:avm/res/network/virtual-network:0.5.2' = {
  name: 'virtualNetworkDeployment'
  params: {
    // Required parameters
    addressPrefixes: [
      addressSpace
    ]
    name: vnetName
    // Non-required parameters
    location: location
    subnets: [
      {
        addressPrefix: '10.201.1.0/24'
        name: systemPoolSubnetName
        networkSecurityGroupResourceId: networkSecurityGroup.outputs.resourceId
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
      }
      {
        addressPrefix: '10.201.2.0/24'
        name: userPool1SubnetName
        networkSecurityGroupResourceId: networkSecurityGroup.outputs.resourceId
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
      }
        {
        addressPrefix: '10.201.3.0/24'
        name: userPool2SubnetName
        networkSecurityGroupResourceId: networkSecurityGroup.outputs.resourceId
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
      }
    ]
    roleAssignments: [
      {
      principalId: userAssignedIdentity.outputs.principalId
      roleDefinitionIdOrName: 'Contributor'
      }
  ]
  }
  dependsOn: [
    userAssignedIdentity // Add explicit dependency for avoiding errors
  ]
}



param privateDnsZoneName string

//It should be a valid resource id and the private dns zone name should be in either of these formats: 'private.eastus2.azmk8s.io,privatelink.eastus2.azmk8s.io,[a-zA-Z0-9-]{1,32}.private.eastus2.azmk8s.io,[a-zA-Z0-9-]{1,32}.privatelink.eastus2.azmk8s.io'
//check and replace if location does not matches exactly with the private dns zone name
//for example if location is 'eastus2' and private dns zone name is 'private.eastus.azmk8s.io' then it will be replaced with 'private.eastus2.azmk8s.io'
//if location is 'eastus2' and private dns zone name is 'privatelink.eastus.azmk8s.io' then it will be replaced with 'privatelink.eastus2.azmk8s.io'
var locationNormalized = replace(toLower(location), ' ', '')
// Simple check for the two standard patterns
var isPrivateZone = startsWith(privateDnsZoneName, 'private.')
var isPrivateLinkZone = startsWith(privateDnsZoneName, 'privatelink.')

// Get correct DNS zone name based on the pattern
var finalPrivateDnsZoneName = isPrivateZone 
                              ? 'private.${locationNormalized}.azmk8s.io' 
                              : (isPrivateLinkZone 
                                ? 'privatelink.${locationNormalized}.azmk8s.io'
                                : privateDnsZoneName)

module privateDnsZone 'br/public:avm/res/network/private-dns-zone:0.7.0' = {
  name: 'privateDnsZoneDeployment'
  params: {
    // Required parameters
    name: finalPrivateDnsZoneName
    // Non-required parameters
    location: 'global'
    roleAssignments: [
      {
        principalId: userAssignedIdentity.outputs.principalId
        roleDefinitionIdOrName: 'Contributor'
      }
    ]
    virtualNetworkLinks: [
      {
        registrationEnabled: true
        virtualNetworkResourceId: virtualNetwork.outputs.resourceId
      }
    ]
  }
}

param aksName string

module managedCluster 'br/public:avm/res/container-service/managed-cluster:0.8.0' = {
  name: 'managedClusterDeployment'
  params: {
    // Required parameters
    name: aksName
    location: location
    primaryAgentPoolProfiles: [
      {
        availabilityZones: [
          3
        ]
        count: 1
        enableAutoScaling: true
        maxCount: 10
        minCount: 3
        mode: 'System'
        name: 'systempool'
        nodeTaints: [
          'CriticalAddonsOnly=true:NoSchedule'
        ]
        osDiskSizeGB: 0
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        vmSize: 'Standard_D2ads_v6'
        vnetSubnetResourceId: virtualNetwork.outputs.subnetResourceIds[0]
      }
    ]
    // Non-required parameters
    aadProfile: {
      aadProfileEnableAzureRBAC: true
      aadProfileManaged: true
    }
    agentPools: [
      {
        availabilityZones: [
          3
        ]
        count: 2
        enableAutoScaling: true
        maxCount: 10
        minCount: 3
        mode: 'User'
        name: 'userpool1'
        osDiskSizeGB: 60
        osDiskType: 'Ephemeral'
        osType: 'Linux'
        scaleSetEvictionPolicy: 'Delete'
        scaleSetPriority: 'Regular'
        type: 'VirtualMachineScaleSets'
        vmSize: 'Standard_D2ads_v6'
        vnetSubnetResourceId: virtualNetwork.outputs.subnetResourceIds[1]
      }
      {
        availabilityZones: [
          3
        ]
        count: 2
        enableAutoScaling: true
        maxCount: 10
        minCount: 3
        mode: 'User'
        name: 'userpool2'
        osDiskSizeGB: 60
        osDiskType: 'Ephemeral'
        osType: 'Linux'
        scaleSetEvictionPolicy: 'Delete'
        scaleSetPriority: 'Regular'
        type: 'VirtualMachineScaleSets'
        vmSize: 'Standard_D2ads_v6'
        vnetSubnetResourceId: virtualNetwork.outputs.subnetResourceIds[2]
      }
    ]
    autoNodeOsUpgradeProfileUpgradeChannel: 'Unmanaged'
    autoUpgradeProfileUpgradeChannel: 'stable'
    dnsServiceIP: '10.10.200.10'
    enablePrivateCluster: true
    managedIdentities: {
      userAssignedResourceIds: [
        userAssignedIdentity.outputs.resourceId
      ]
    }
    networkPlugin: 'azure'
    networkPolicy: 'azure'
    omsAgentEnabled: true
    privateDNSZone: privateDnsZone.outputs.resourceId
    serviceCidr: '10.10.200.0/24'
    skuTier: 'Standard'
  }
}
